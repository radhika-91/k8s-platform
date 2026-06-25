# Observability — Mimir

Deploys **Mimir** metrics storage into the `platform` namespace.

Toggle: `features.observabilityMimir.enabled` in `clusters/<name>/k8s-features.yaml`.

Remote write endpoint: `http://observability-mimir-gateway/api/v1/push`

Deploy before Grafana and agent charts (sync wave 5).
