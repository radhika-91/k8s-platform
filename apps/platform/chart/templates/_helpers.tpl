{{/*
Resolve sync policy for a feature Application.
Cluster-level .Values.syncPolicy provides defaults; features.<name>.syncPolicy overrides per feature.
All fields default to true when unset. Use hasKey checks so explicit false is respected (Helm default treats false as empty).
*/}}
{{- define "platform-apps.resolvedSyncPolicy" -}}
{{- $clusterPolicy := .clusterPolicy | default dict -}}
{{- $featurePolicy := .featurePolicy | default dict -}}
{{- $automated := true -}}
{{- if hasKey $clusterPolicy "automated" -}}
{{- $automated = $clusterPolicy.automated -}}
{{- end -}}
{{- if hasKey $featurePolicy "automated" -}}
{{- $automated = $featurePolicy.automated -}}
{{- end -}}
{{- $prune := true -}}
{{- if hasKey $clusterPolicy "prune" -}}
{{- $prune = $clusterPolicy.prune -}}
{{- end -}}
{{- if hasKey $featurePolicy "prune" -}}
{{- $prune = $featurePolicy.prune -}}
{{- end -}}
{{- $selfHeal := true -}}
{{- if hasKey $clusterPolicy "selfHeal" -}}
{{- $selfHeal = $clusterPolicy.selfHeal -}}
{{- end -}}
{{- if hasKey $featurePolicy "selfHeal" -}}
{{- $selfHeal = $featurePolicy.selfHeal -}}
{{- end -}}
{{- dict "automated" $automated "prune" $prune "selfHeal" $selfHeal | toYaml -}}
{{- end -}}

{{/*
Render spec.syncPolicy for a feature Application (automated block + syncOptions).
*/}}
{{- define "platform-apps.syncPolicySpec" -}}
{{- $resolved := include "platform-apps.resolvedSyncPolicy" . | fromYaml -}}
{{- if $resolved.automated }}
automated:
  prune: {{ $resolved.prune }}
  selfHeal: {{ $resolved.selfHeal }}
{{- end }}
syncOptions:
  - CreateNamespace=true
  - ServerSideApply=true
{{- end -}}
