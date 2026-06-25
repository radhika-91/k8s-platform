# Observability — Grafana

Deploys **Grafana** into the `platform` namespace with preconfigured Mimir, Loki, and Tempo datasources.

Toggle: `features.observabilityGrafana.enabled` in `clusters/<name>/k8s-features.yaml`.

Requires Loki, Mimir, and Tempo backends (sync wave 6 — after wave 5 backends).

```bash
make grafana-ui   # http://localhost:3000 (admin / admin on Kind)
```
