# Storage

Wraps [local-path-provisioner](https://github.com/rancher/local-path-provisioner) for Kind clusters. Replace with cloud CSI drivers in production via additional value files (`values-eks.yaml`, etc.).

Toggle: `features.storage.enabled` in `clusters/<name>/k8s-features.yaml`.
