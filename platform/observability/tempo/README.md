# Observability — Tempo

Deploys **Tempo** trace storage into the `platform` namespace.

Toggle: `features.observabilityTempo.enabled` in `clusters/<name>/k8s-features.yaml`.

OTLP ingest: `observability-tempo:4317` (gRPC), `:4318` (HTTP)

Deploy before Grafana (sync wave 5).
