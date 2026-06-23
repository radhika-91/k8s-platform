#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
PLATFORM_NAMESPACE="${PLATFORM_NAMESPACE:-platform}"
CLUSTER_NAME="${CLUSTER_NAME:-k8s-platform}"
CLUSTER_CONFIG="${CLUSTER_CONFIG:-kind-local}"
GIT_REPO_URL="${GIT_REPO_URL:-}"
GIT_REVISION="${GIT_REVISION:-HEAD}"

kubectl config use-context "kind-${CLUSTER_NAME}"

if [[ -z "${GIT_REPO_URL}" ]]; then
  echo "ERROR: GIT_REPO_URL is required."
  echo "Example: GIT_REPO_URL=https://github.com/your-org/k8s-platform.git make apply-root-app"
  exit 1
fi

if [[ ! -f "${REPO_ROOT}/clusters/${CLUSTER_CONFIG}/k8s-features.yaml" ]]; then
  echo "ERROR: clusters/${CLUSTER_CONFIG}/k8s-features.yaml not found."
  echo "Set CLUSTER_CONFIG to match your cluster config directory name."
  exit 1
fi

echo "Applying AppProjects..."
kubectl apply -f "${REPO_ROOT}/cicd/argocd/config/appprojects/"

echo "Ensuring namespace '${PLATFORM_NAMESPACE}' exists..."
kubectl create namespace "${PLATFORM_NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

render_template() {
  local src="$1"
  sed \
    -e "s|\${GIT_REPO_URL}|${GIT_REPO_URL}|g" \
    -e "s|\${GIT_REVISION}|${GIT_REVISION}|g" \
    -e "s|\${CLUSTER_CONFIG}|${CLUSTER_CONFIG}|g" \
    "${src}"
}

echo "Applying platform Application for cluster config '${CLUSTER_CONFIG}' (repo: ${GIT_REPO_URL})..."
render_template "${REPO_ROOT}/cicd/argocd/applications/platform-application.yaml.tpl" | kubectl apply -f -

echo "Applying Argo CD self-management Application..."
render_template "${REPO_ROOT}/cicd/argocd/applications/argocd-self.yaml.tpl" | kubectl apply -f -

echo "Applications applied. Check sync status:"
echo "  kubectl get applications -n ${PLATFORM_NAMESPACE}"
echo "  kubectl get applications -n ${ARGOCD_NAMESPACE}   # argocd-config only"
