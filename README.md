# tf-podinfo-module

Minimal **version trigger** for the `infra-demo` / `infra-prod` Pattern A demo.

Kargo's `podinfo-module` Warehouse watches this repo's **git tags** (SemVer) as the
"platform version". The actual OpenTofu that runs during a promotion lives in
[`gitops-tenants/infra/tofu`](https://github.com/himeshpanc/gitops-tenants) and uses
the `vault` provider against OpenBao — this module holds no real infra, only tags.

(Analogous to `tenant-platform-module`, which triggers the fleet demo.)
