# Version-trigger module for the infra-demo / infra-prod (Pattern A) track.
# Its git TAGS are the "platform version" Kargo promotes across the infra
# environments; the tofu that actually runs lives in gitops-tenants/infra/tofu
# (vault provider -> OpenBao). Intentionally minimal — only the tag matters.
variable "app" {
  type    = string
  default = "infra"
}

output "version" {
  value = "infra-platform-module"
}
