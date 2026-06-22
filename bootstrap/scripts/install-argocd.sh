#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
ARGOCD_RELEASE="${ARGOCD_RELEASE:-argocd}"
CLUSTER_NAME="${CLUSTER_NAME:-k8s-platform}"
ENVIRONMENT="${ENVIRONMENT:-kind}"

kubectl config use-context "kind-${CLUSTER_NAME}"

echo "Ensuring namespace '${ARGOCD_NAMESPACE}' exists..."
kubectl create namespace "${ARGOCD_NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

echo "Updating Helm dependencies for Argo CD..."
helm dependency update "${REPO_ROOT}/cicd/argocd/helm"

VALUES_FILES=(-f "${REPO_ROOT}/cicd/argocd/helm/values.yaml")
if [[ -f "${REPO_ROOT}/cicd/argocd/helm/values-${ENVIRONMENT}.yaml" ]]; then
  VALUES_FILES+=(-f "${REPO_ROOT}/cicd/argocd/helm/values-${ENVIRONMENT}.yaml")
fi

echo "Installing Argo CD via Helm..."
helm upgrade --install "${ARGOCD_RELEASE}" "${REPO_ROOT}/cicd/argocd/helm" \
  --namespace "${ARGOCD_NAMESPACE}" \
  "${VALUES_FILES[@]}" \
  --wait \
  --timeout 10m

echo "Waiting for Argo CD server to be ready..."
kubectl rollout status deployment/argocd-server -n "${ARGOCD_NAMESPACE}" --timeout=5m

echo "Argo CD installed. Run 'make argocd-password' to retrieve the admin password."
