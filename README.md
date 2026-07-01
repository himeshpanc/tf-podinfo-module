# tf-podinfo-module (demo)

A tiny Terraform module that deploys **podinfo** into a tenant namespace via the
kubernetes provider. Used by the Kargo + Flux tofu-controller demo.

Each **git tag** pins a podinfo version (the `local.image` in `main.tf`):

| tag | podinfo |
|-----|---------|
| `v6.13.0` | 6.13.0 |
| `v6.14.0` | 6.14.0 |

A "promotion" = bumping the module `ref` a tenant root points at. Kargo's
`hcl-update` step does that; the Warehouse watches these tags.

```hcl
module "podinfo" {
  source    = "git::https://github.com/himeshpanc/tf-podinfo-module.git//?ref=v6.13.0"
  namespace = "tenant-a"
}
```
