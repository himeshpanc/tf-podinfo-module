# tf-podinfo-module

Minimal **version trigger** for the **infra** demo — `infra-demo` → `infra-prod`
(Kargo + Flux, Pattern A).

This repo holds no real logic — each **semver git tag** is a "platform version" that
Kargo promotes: **infra-demo (auto) → infra-prod (PR-gated)**, with verification and a
soak window.

The actual OpenTofu each promotion runs lives in
[`gitops-tenants/infra/tofu`](https://github.com/himeshpanc/gitops-tenants) and uses the
`vault` provider against OpenBao (no cluster creds); Flux then applies the `podinfo` app.
The tag here is just the input.

> **infra-demo** runs the tofu **natively in Kargo**; **infra-prod** delegates the apply to
> the Flux **tofu-controller** (Kargo plans, the controller applies + owns state in a Secret).

## How it's used
- Kargo's `podinfo-module` Warehouse watches this repo's **SemVer tags** → Freight.
- Tagging a new version **kicks off an infra rollout** (demo first, then prod via PR).

> ⚠️ Demo / workshop repo — generic content only; the tag is what matters, not the code.
> Analogous to [`tenant-platform-module`](https://github.com/himeshpanc/tenant-platform-module),
> which triggers the fleet demo.
