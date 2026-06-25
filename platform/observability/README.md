# Observability

Platform observability uses separate Helm charts (one Argo CD Application each):

| Chart | Path | Role |
|-------|------|------|
| **loki** | [`loki/helm`](loki/helm/) | Log storage |
| **mimir** | [`mimir/helm`](mimir/helm/) | Metrics storage |
| **tempo** | [`tempo/helm`](tempo/helm/) | Trace storage |
| **grafana** | [`grafana/helm`](grafana/helm/) | Dashboards |
| **prometheus-operator-crds** | [`prometheus-operator-crds/helm`](prometheus-operator-crds/helm/) | ServiceMonitor / PodMonitor CRDs |
| **k8s-monitoring** | [`k8s-monitoring/helm`](k8s-monitoring/helm/) | **Alloy path** — collectors + app metric scraping |
| **otel** | [`otel/helm`](otel/helm/) | **OTel path** — direct OpenTelemetry Collector agents |

## Collector paths (pick one)

**Alloy (Grafana k8s-monitoring + Prometheus Operator CRDs):**

```yaml
features:
  observabilityLoki: { enabled: true }
  observabilityMimir: { enabled: true }
  observabilityGrafana: { enabled: true }
  observabilityPrometheusOperatorCrds: { enabled: true }
  observabilityK8sMonitoring: { enabled: true }
  observabilityOtel: { enabled: false }
```

**OpenTelemetry (direct agents):**

```yaml
features:
  observabilityLoki: { enabled: true }
  observabilityMimir: { enabled: true }
  observabilityGrafana: { enabled: true }
  observabilityPrometheusOperatorCrds: { enabled: false }
  observabilityK8sMonitoring: { enabled: false }
  observabilityOtel:
    enabled: true
    values:
      agents:
        logs: { enabled: true }
        nodeMetrics: { enabled: true }
        clusterMetrics: { enabled: true }
```

Do not enable **k8s-monitoring** and **otel** for the same telemetry — that duplicates logs and metrics.

**Deploy order:** Loki / Mimir / Tempo (wave 5) → Grafana + Prometheus Operator CRDs (wave 6) → k8s-monitoring or otel (7–8).

See per-chart READMEs in each subdirectory.
