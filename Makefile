.PHONY: help kind-up kind-down bootstrap apply-root-app configure-repo argocd-password argocd-ui lint helm-deps clean

CLUSTER_NAME ?= k8s-platform
ENVIRONMENT  ?= kind
ARGOCD_NS    ?= argocd
GIT_REPO_URL ?=
GIT_REVISION ?= HEAD

help:
	@echo "K8s Platform GitOps - local Kind targets"
	@echo ""
	@echo "  make kind-up          Create Kind cluster"
	@echo "  make kind-down        Delete Kind cluster"
	@echo "  make bootstrap        Install Argo CD via Helm"
	@echo "  make apply-root-app   Apply root Application (requires GIT_REPO_URL=...)"
	@echo "  make configure-repo   Replace YOUR_ORG repo URL across manifests (GIT_REPO_URL=...)"
	@echo "  make argocd-password  Print Argo CD admin password"
	@echo "  make argocd-ui        Port-forward Argo CD UI to localhost:8080"
	@echo "  make helm-deps        Update Helm chart dependencies"
	@echo "  make lint             Lint Helm charts and validate YAML"
	@echo "  make clean            Remove Helm dependency archives"

kind-up:
	@CLUSTER_NAME=$(CLUSTER_NAME) ./bootstrap/scripts/create-kind-cluster.sh

kind-down:
	@kind delete cluster --name $(CLUSTER_NAME) || true

bootstrap: helm-deps
	@CLUSTER_NAME=$(CLUSTER_NAME) ENVIRONMENT=$(ENVIRONMENT) ./bootstrap/scripts/install-argocd.sh

apply-root-app:
	@CLUSTER_NAME=$(CLUSTER_NAME) GIT_REPO_URL=$(GIT_REPO_URL) GIT_REVISION=$(GIT_REVISION) \
		./bootstrap/scripts/apply-root-app.sh

configure-repo:
	@test -n "$(GIT_REPO_URL)" || (echo "ERROR: set GIT_REPO_URL=https://github.com/radhika-91/k8s-platform.git"; exit 1)
	@echo "Updating repo URL to $(GIT_REPO_URL)..."
	@find apps clusters cicd/argocd/applications -type f \( -name '*.yaml' -o -name '*.yaml.tpl' \) -print0 | \
		xargs -0 sed -i.bak "s|https://github.com/YOUR_ORG/k8s-platform.git|$(GIT_REPO_URL)|g"
	@find apps clusters cicd/argocd/applications -type f -name '*.bak' -delete
	@echo "Done. Review changes and commit."

argocd-password:
	@kubectl -n $(ARGOCD_NS) get secret argocd-initial-admin-secret \
		-o jsonpath='{.data.password}' | base64 -d; echo

argocd-ui:
	@kubectl -n $(ARGOCD_NS) port-forward svc/argocd-server 8080:443

helm-deps:
	@find . -name Chart.yaml -not -path './lib/*' | while read -r chart; do \
		dir=$$(dirname "$$chart"); \
		if grep -q '^dependencies:' "$$chart" 2>/dev/null; then \
			echo "Updating dependencies: $$dir"; \
			helm dependency update "$$dir"; \
		fi; \
	done

lint: helm-deps
	@./scripts/lint.sh

clean:
	@find . -path '*/charts/*.tgz' -delete 2>/dev/null || true
