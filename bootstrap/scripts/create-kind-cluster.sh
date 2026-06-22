#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CLUSTER_NAME="${CLUSTER_NAME:-k8s-platform}"
KIND_CONFIG="${KIND_CONFIG:-${REPO_ROOT}/bootstrap/kind/kind-config.yaml}"

if kind get clusters 2>/dev/null | grep -qx "${CLUSTER_NAME}"; then
  echo "Kind cluster '${CLUSTER_NAME}' already exists."
  kubectl cluster-info --context "kind-${CLUSTER_NAME}" >/dev/null
  exit 0
fi

echo "Creating Kind cluster '${CLUSTER_NAME}'..."
kind create cluster --name "${CLUSTER_NAME}" --config "${KIND_CONFIG}"
kubectl cluster-info --context "kind-${CLUSTER_NAME}"
echo "Kind cluster '${CLUSTER_NAME}' is ready."
