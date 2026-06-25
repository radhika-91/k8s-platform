# Observability — Prometheus Operator CRDs

Installs **Prometheus Operator CRDs** cluster-wide (ServiceMonitor, PodMonitor, Probe, ScrapeConfig, PrometheusRule).

Does **not** run the Prometheus Operator controller or a Prometheus server. Alloy (via [k8s-monitoring](../k8s-monitoring/)) watches these CRs and remote-writes to Mimir.

Toggle: `features.observabilityPrometheusOperatorCrds.enabled` in `clusters/<name>/k8s-features.yaml`.

**Deploy before** `observability-k8s-monitoring` (sync wave 6 vs 7).

When using the Alloy path with app ServiceMonitors, enable both:

```yaml
features:
  observabilityPrometheusOperatorCrds:
    enabled: true
  observabilityK8sMonitoring:
    enabled: true
```

Verify: `kubectl get crd servicemonitors.monitoring.coreos.com`
