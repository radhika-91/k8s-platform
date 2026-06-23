# Platform application generator

Helm chart that renders Argo CD `Application` manifests for enabled platform features.
All platform Applications and their workloads deploy to the `platform` namespace.

Each cluster runs its own Argo CD instance. At bootstrap, `make apply-root-app` applies a
single **platform Application** scoped to that cluster's config:

```
clusters/kind-local/k8s-features.yaml  →  Application platform (platform ns)  →  feature Applications (ingress, storage, ...)
```

There is no ApplicationSet — other clusters' configs in `clusters/` are ignored by each Argo CD instance.
