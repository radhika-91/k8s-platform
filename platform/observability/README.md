# Observability

Wraps [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) for metrics and Grafana.

Toggle: `features.observability.enabled` in `clusters/<name>/cluster.yaml`.

Kind defaults use reduced retention and resources. Change the Grafana admin password before enabling outside local clusters.
