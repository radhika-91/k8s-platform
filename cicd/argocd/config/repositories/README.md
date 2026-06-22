# Repository credentials

Do not commit secrets to this directory.

In production, configure private repo access via:

- External Secrets Operator + cloud secret backend
- Argo CD `Repository` CRs applied from encrypted manifests (SOPS)
- Argo CD CLI: `argocd repo add`

For public repositories, no credentials are required.
