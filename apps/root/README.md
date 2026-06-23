# Workload applications (future)

This directory is reserved for team/application Argo CD manifests.

Platform infrastructure (ingress, storage, cert-manager, etc.) is deployed by the
cluster-scoped **platform Application** bootstrap target, which renders
`apps/platform/chart` using `clusters/<name>/k8s-features.yaml`.
