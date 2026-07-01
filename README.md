# tf-podinfo-module (demo)

A small Terraform module that provisions a **tenant** via the kubernetes provider.
Used by the Kargo + Flux tofu-controller demo (the `tf/` track in `gitops-tenants`).

Each **git tag** is a module version the Warehouse watches; a "promotion" = Kargo's
`hcl-update` step bumping the module `?ref=` a tenant root points at.

| tag | podinfo | what the module provisions |
|-----|---------|----------------------------|
| `6.13.0` | 6.13.0 | podinfo Deployment + Service |
| `6.14.0` | 6.14.0 | podinfo Deployment + Service |
| `6.15.0` | 6.14.0 | **full tenant**: podinfo + **ExternalSecret** (from OpenBao) + **Reloader** annotation + greeting wired from the secret (`PODINFO_UI_MESSAGE`) |

> Tags are plain semver (no `v` prefix) so they match podinfo's reported `/version`
> for verification. `6.15.0` keeps podinfo at 6.14.0 — the version bump is the
> *module feature* (secret wiring), so the demo verifies the **greeting** (proving
> the tofu → ESO → Reloader chain), not the image tag.

## Usage

```hcl
module "podinfo" {
  source    = "git::https://github.com/himeshpanc/tf-podinfo-module.git//?ref=6.15.0"
  namespace = "tenant-a"
  # replicas = 2   # optional, default 1
}
```

Requires (in the cluster): a kubernetes provider configured for in-cluster auth,
and for `6.15.0` — the External-Secrets `ClusterSecretStore` named `openbao` plus a
`secret/tenant-config` key `greeting` in OpenBao.
