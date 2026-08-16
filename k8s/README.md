# Manyfold Kubernetes deployment

Both overlays deploy the `manyfold` workload into the `openscad` namespace.

## Local

The local overlay includes ephemeral PostgreSQL and Redis instances plus a
PVC for an empty test library. It does not require the Talos operators or NAS.

```sh
kubectl config current-context
kubectl apply -k k8s/overlays/local
kubectl -n openscad rollout status deployment/manyfold
kubectl -n openscad port-forward service/manyfold 3214:3214
```

Open <http://localhost:3214>, then create a Manyfold library using `/library`
as its filesystem path.

## Talos

The Talos overlay adds CloudNativePG, Dragonfly, MinIO-backed database backups,
the static Synology NFS model library, and the `manyfold.talos00` IngressRoute.
Before syncing it, create a `manyfold-secret-key-base` field on the `openscad`
item in the `catalyst-eso` 1Password vault.

The Argo CD `Application` is registered from `talos-homelab` and tracks
`k8s/overlays/talos00` on this repository's `main` branch.
