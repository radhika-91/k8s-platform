# Observability — OpenTelemetry Collector agents

Deploys **OpenTelemetry Collector** telemetry agents into the `platform` namespace. Requires [Loki](../loki/) and [Mimir](../mimir/) backends.

This is the **OTel path** — an alternative to [k8s-monitoring](../k8s-monitoring/) (Alloy). Enable one collector stack, not both.

| Agent | Deploys as | Collects |
|-------|------------|----------|
| **logs** | DaemonSet | Pod / container logs → Loki |
| **clusterMetrics** | Deployment | K8s cluster metrics → Mimir |
| **nodeMetrics** | DaemonSet | Node / kubelet / host metrics → Mimir |

Toggle: `features.observabilityOtel.enabled` in `clusters/<name>/k8s-features.yaml`.

```yaml
# OTel path — all agents via OpenTelemetry
features:
  observabilityLoki:
    enabled: true
  observabilityMimir:
    enabled: true
  observabilityGrafana:
    enabled: true
  observabilityK8sMonitoring:
    enabled: false
  observabilityOtel:
    enabled: true
    values:
      agents:
        logs: { enabled: true }
        nodeMetrics: { enabled: true }
        clusterMetrics: { enabled: true }
```

Processors and sampling are configured in structured YAML under `otel-logs`, `otel-node-metrics`, etc. in `helm/values.yaml` — see [OpenTelemetry Collector docs](https://opentelemetry.io/docs/collector/).

Verify: `kubectl get pods -n platform -l app.kubernetes.io/name=opentelemetry-collector`
