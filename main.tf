terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
  }
}

variable "namespace" {
  type        = string
  description = "Tenant namespace to deploy podinfo into."
}

variable "replicas" {
  type    = number
  default = 1
}

# The podinfo version this MODULE TAG ships. Each git tag of this module pins a
# version; promoting = bumping the module ref (Kargo's hcl-update does this).
locals {
  image = "ghcr.io/stefanprodan/podinfo:6.13.0"
}

resource "kubernetes_namespace" "tenant" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment" "podinfo" {
  metadata {
    name      = "podinfo"
    namespace = kubernetes_namespace.tenant.metadata[0].name
    labels    = { app = "podinfo" }
  }
  spec {
    replicas = var.replicas
    selector {
      match_labels = { app = "podinfo" }
    }
    template {
      metadata {
        labels = { app = "podinfo" }
      }
      spec {
        container {
          name  = "podinfo"
          image = local.image
          port {
            container_port = 9898
            name           = "http"
          }
          readiness_probe {
            http_get {
              path = "/readyz"
              port = "http"
            }
          }
          liveness_probe {
            http_get {
              path = "/healthz"
              port = "http"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "podinfo" {
  metadata {
    name      = "podinfo"
    namespace = var.namespace
    labels    = { app = "podinfo" }
  }
  spec {
    selector = { app = "podinfo" }
    port {
      name        = "http"
      port        = 9898
      target_port = "http"
    }
  }
}

output "version" {
  value = local.image
}
