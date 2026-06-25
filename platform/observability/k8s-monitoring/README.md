# Observability — k8s-monitoring (Alloy)

Deploys [Grafana k8s-monitoring](https://github.com/grafana/k8s-monitoring-helm) — Alloy collectors managed by the Alloy Operator — wired to self-hosted **Loki** and **Mimir** in this cluster.

Toggle: `features.observabilityK8sMonitoring.enabled` in `clusters/<name>/k8s-features.yaml`.

Requires `observability-loki`, `observability-mimir`, and [`observability-prometheus-operator-crds`](../prometheus-operator-crds/) (wave 6) before this chart (wave 7).

## App metrics (ServiceMonitor / PodMonitor)

With `prometheusOperatorObjects` enabled (default in `values.yaml`), Alloy scrapes **ServiceMonitor**, **PodMonitor**, and **Probe** CRs and remote-writes to Mimir. App charts ship those CRs; the platform provides the CRDs and collector.

## Alloy path vs OTel path

Use **one** collector stack per cluster — not both for the same telemetry:

| Path | Feature | Runtime |
|------|---------|---------|
| Grafana-managed Alloy | `observabilityK8sMonitoring` | k8s-monitoring chart |
| Direct OTel agents | `observabilityOtel` | OpenTelemetry Collector subcharts |

```yaml
# Alloy path (this chart)
features:
  observabilityLoki:
    enabled: true
  observabilityMimir:
    enabled: true
  observabilityPrometheusOperatorCrds:
    enabled: true
  observabilityK8sMonitoring:
    enabled: true
  observabilityOtel:
    enabled: false

# OTel path (alternative)
features:
  observabilityLoki:
    enabled: true
  observabilityMimir:
    enabled: true
  observabilityK8sMonitoring:
    enabled: false
  observabilityOtel:
    enabled: true
```

## Customization (drops, sampling, extra processing)

Most toggles are YAML under `features.observabilityK8sMonitoring.values.k8s-monitoring`. Advanced pipeline changes use River in `collectors.<name>.extraConfig`:

```yaml
features:
  observabilityK8sMonitoring:
    enabled: true
    values:
      k8s-monitoring:
        collectors:
          alloy-logs:
            extraConfig: |-
              loki.process "drop_kube_system" {
                stage.match {
                  selector = `{namespace="kube-system"}`
                  action   = "drop"
                }
                forward_to = []
              }
```

See [Grafana k8s-monitoring customization docs](https://grafana.com/docs/grafana-cloud/monitor-infrastructure/kubernetes-monitoring/configuration/helm-chart-config/helm-chart/customize-helm-chart/).
