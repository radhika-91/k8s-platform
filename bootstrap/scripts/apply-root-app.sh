#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
CLUSTER_NAME="${CLUSTER_NAME:-k8s-platform}"
GIT_REPO_URL="${GIT_REPO_URL:-}"
GIT_REVISION="${GIT_REVISION:-HEAD}"

kubectl config use-context "kind-${CLUSTER_NAME}"

if [[ -z "${GIT_REPO_URL}" ]]; then
  echo "ERROR: GIT_REPO_URL is required."
  echo "Example: GIT_REPO_URL=https://github.com/your-org/k8s-platform.git make apply-root-app"
  exit 1
fi

echo "Applying AppProjects..."
kubectl apply -f "${REPO_ROOT}/cicd/argocd/config/appprojects/"

render_template() {
  local src="$1"
  sed \
    -e "s|\${GIT_REPO_URL}|${GIT_REPO_URL}|g" \
    -e "s|\${GIT_REVISION}|${GIT_REVISION}|g" \
    "${src}"
}

echo "Rendering and applying root Application (repo: ${GIT_REPO_URL})..."
render_template "${REPO_ROOT}/cicd/argocd/applications/root-application.yaml.tpl" | kubectl apply -f -

echo "Applying Argo CD self-management Application..."
render_template "${REPO_ROOT}/cicd/argocd/applications/argocd-self.yaml.tpl" | kubectl apply -f -

echo "Root Applications applied. Check sync status:"
echo "  kubectl get applications -n ${ARGOCD_NAMESPACE}"
