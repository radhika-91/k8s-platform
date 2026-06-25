# k8s-platform

GitOps-driven Kubernetes platform management using **Argo CD**, **Helm**, and feature toggles per cluster. Designed for local **Kind** testing and evolution to multi-cloud production.

## Architecture

```
Bootstrap (once)          GitOps (ongoing)
─────────────────         ───────────────────────────────────
make kind-up         →    platform Application (this cluster only)
make bootstrap       →      └─ Generator chart → Feature Applications
make apply-root-app  →           └─ ingress, storage, ... (toggled)
```

One Argo CD instance per cluster. Each cluster bootstraps with `CLUSTER_CONFIG`
pointing at its own `clusters/<name>/k8s-features.yaml` — it never reads other clusters' configs.

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

# 3. Push this repo to a Git remote, then bootstrap GitOps for this cluster
export GIT_REPO_URL=https://github.com/YOUR_ORG/k8s-platform.git
make apply-root-app CLUSTER_CONFIG=kind-local

# 4. Access Argo CD UI
make argocd-password
make argocd-ui   # https://localhost:8080 (accept self-signed cert)
```

## Feature toggles

Edit [`clusters/kind-local/k8s-features.yaml`](clusters/kind-local/k8s-features.yaml):

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

Features deploy in waves: storage → ingress → cert-manager → external-secrets → observability backends (loki/mimir/tempo) → grafana + prometheus-operator-crds → k8s-monitoring or otel agents → policy.

## Repository layout

| Path | Purpose |
|------|---------|
| [`bootstrap/`](bootstrap/) | One-time cluster + Argo CD install (not GitOps-managed) |
| [`cicd/argocd/`](cicd/argocd/) | Argo CD Helm values, config, root applications |
| [`clusters/`](clusters/) | Per-cluster metadata and feature toggles |
| [`docs/templates/`](docs/templates/) | Cluster config template for new clusters |
| [`platform/`](platform/) | Wrapper Helm charts for each platform feature |
| [`apps/`](apps/) | Platform generator chart and future workload apps |
| [`environments/`](environments/) | Shared value layers (base / kind / prod) |

## Makefile targets

| Target | Description |
|--------|-------------|
| `make kind-up` | Create Kind cluster |
| `make kind-down` | Delete Kind cluster |
| `make bootstrap` | Install Argo CD via Helm |
| `make apply-root-app` | Apply platform + argocd-config Applications (`GIT_REPO_URL`, `CLUSTER_CONFIG`) |
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

1. Add `clusters/prod-<cloud>/k8s-features.yaml` with production toggles
2. Bootstrap a **separate** Argo CD on that cluster with `CLUSTER_CONFIG=prod-<cloud>`
3. Add cloud-specific value files (`values-eks.yaml`, etc.) under each feature
4. Enable manual sync / sync windows for production
5. Wire SOPS or External Secrets for repo credentials
6. Restrict AppProjects and enable policy (Kyverno)

## Platform features

| Feature | Chart | Kind default |
|---------|-------|--------------|
| storage | local-path-provisioner | enabled |
| ingress | ingress-nginx | enabled |
| cert-manager | cert-manager | disabled |
| external-secrets | external-secrets | disabled |
| observability-loki | `platform/observability/loki` | disabled |
| observability-mimir | `platform/observability/mimir` | disabled |
| observability-tempo | `platform/observability/tempo` | disabled |
| observability-grafana | `platform/observability/grafana` | disabled |
| observability-prometheus-operator-crds | `platform/observability/prometheus-operator-crds` — ServiceMonitor CRDs | disabled |
| observability-k8s-monitoring | `platform/observability/k8s-monitoring` — Alloy via Grafana k8s-monitoring | disabled |
| observability-otel | `platform/observability/otel` — direct OpenTelemetry Collector agents | disabled |
| policy | kyverno | disabled |
