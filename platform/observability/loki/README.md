# Observability — Loki

Deploys **Loki** log aggregation into the `platform` namespace.

Toggle: `features.observabilityLoki.enabled` in `clusters/<name>/k8s-features.yaml`.

Service: `observability-loki:3100`

Deploy before agent charts (sync wave 5).
