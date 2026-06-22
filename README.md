# k8s-platform

GitOps-driven Kubernetes platform management using **Argo CD**, **Helm**, and feature toggles per cluster. Designed for local **Kind** testing and evolution to multi-cloud production.

## Architecture

```
Bootstrap (once)          GitOps (ongoing)
─────────────────         ───────────────────────────────────
make kind-up         →    Root Application
make bootstrap       →      └─ ApplicationSet (per cluster)
make apply-root-app  →           └─ Feature Applications (toggled)
```

Each cluster declares enabled features in `clusters/<name>/cluster.yaml`. Disabled features are not deployed.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm 3](https://helm.sh/docs/intro/install/) (>= 3.12)
- A Git remote Argo CD can reach (GitHub, GitLab, etc.)

Optional: `yq` for local linting (`brew install yq`)

## Quick start (Kind)

```bash
# 0. Set your Git remote (once)
make configure-repo GIT_REPO_URL=https://github.com/YOUR_ORG/k8s-platform.git

# 1. Create local cluster
make kind-up

# 2. Install Argo CD (Helm bootstrap)
make bootstrap

# 3. Push this repo to a Git remote, then apply root Application
export GIT_REPO_URL=https://github.com/YOUR_ORG/k8s-platform.git
make apply-root-app

# 4. Access Argo CD UI
make argocd-password
make argocd-ui   # https://localhost:8080 (accept self-signed cert)
```

## Feature toggles

Edit [`clusters/kind-local/cluster.yaml`](clusters/kind-local/cluster.yaml):

```yaml
features:
  storage:
    enabled: true
  ingress:
    enabled: true
  certManager:
    enabled: false   # enable when testing TLS
```

Commit and push; Argo CD syncs only enabled features.

### Sync order

Features deploy in waves: storage → ingress → cert-manager → external-secrets → observability → policy.

## Repository layout

| Path | Purpose |
|------|---------|
| [`bootstrap/`](bootstrap/) | One-time cluster + Argo CD install (not GitOps-managed) |
| [`cicd/argocd/`](cicd/argocd/) | Argo CD Helm values, config, root applications |
| [`clusters/`](clusters/) | Per-cluster metadata and feature toggles |
| [`docs/templates/`](docs/templates/) | Cluster config template for new clusters |
| [`platform/`](platform/) | Wrapper Helm charts for each platform feature |
| [`apps/`](apps/) | Argo CD ApplicationSet and application generator |
| [`environments/`](environments/) | Shared value layers (base / kind / prod) |

## Makefile targets

| Target | Description |
|--------|-------------|
| `make kind-up` | Create Kind cluster |
| `make kind-down` | Delete Kind cluster |
| `make bootstrap` | Install Argo CD via Helm |
| `make apply-root-app` | Apply root Application (`GIT_REPO_URL` required) |
| `make argocd-password` | Print admin password |
| `make argocd-ui` | Port-forward UI to :8080 |
| `make lint` | Helm lint + YAML validation |
| `make helm-deps` | Update chart dependencies |

## Conventions

- **Folders**: `kebab-case` (e.g. `external-secrets`)
- **Feature keys**: `camelCase` in YAML (e.g. `certManager`)
- **Branches**: `main` is desired state; per-cluster overrides live in `clusters/`
- **Charts**: Pin upstream versions in `Chart.yaml`; never use `@latest`
- **Secrets**: Never commit secrets; use External Secrets in production

## Production path

1. Add `clusters/prod-<cloud>/cluster.yaml` with production toggles
2. Add cloud-specific value files (`values-eks.yaml`, etc.) under each feature
3. Enable manual sync / sync windows for production
4. Wire SOPS or External Secrets for repo credentials
5. Restrict AppProjects and enable policy (Kyverno)

## Platform features

| Feature | Chart | Kind default |
|---------|-------|--------------|
| storage | local-path-provisioner | enabled |
| ingress | ingress-nginx | enabled |
| cert-manager | cert-manager | disabled |
| external-secrets | external-secrets | disabled |
| observability | kube-prometheus-stack | disabled |
| policy | kyverno | disabled |
