apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${CLUSTER_CONFIG}-platform
  namespace: platform
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: platform
  source:
    repoURL: ${GIT_REPO_URL}
    targetRevision: ${GIT_REVISION}
    path: apps/platform/chart
    helm:
      valueFiles:
        - ../../../clusters/${CLUSTER_CONFIG}/k8s-features.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: platform
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
