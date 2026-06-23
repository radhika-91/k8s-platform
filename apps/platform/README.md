# Platform application generator

Helm chart that renders Argo CD `Application` manifests for enabled platform features.

Each cluster runs its own Argo CD instance. At bootstrap, `make apply-root-app` applies a
single **platform Application** scoped to that cluster's config:

```
clusters/kind-local/k8s-features.yaml  →  Application kind-local-platform  →  feature Applications
```

There is no ApplicationSet — other clusters' configs in `clusters/` are ignored by each Argo CD instance.
