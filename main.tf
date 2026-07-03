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

locals {
  image = "ghcr.io/stefanprodan/podinfo:6.14.0"
}

resource "kubernetes_namespace" "tenant" {
  metadata {
    name = var.namespace
  }
}

# --- Secret wiring: pull tenant config from the OpenBao hub via External-Secrets ---
resource "kubernetes_manifest" "podinfo_config" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "podinfo-config"
      namespace = kubernetes_namespace.tenant.metadata[0].name
    }
    spec = {
      refreshInterval = "15s"
      secretStoreRef  = { name = "openbao", kind = "ClusterSecretStore" }
      target          = { name = "podinfo-config", creationPolicy = "Owner" }
      data = [
        { secretKey = "greeting", remoteRef = { key = "tenant-config", property = "greeting" } },
      ]
    }
  }
}

resource "kubernetes_deployment" "podinfo" {
  metadata {
    name      = "podinfo"
    namespace = kubernetes_namespace.tenant.metadata[0].name
    labels    = { app = "podinfo", "app.kubernetes.io/version" = "6.23.0" }
    annotations = {
      # Reloader restarts this Deployment when the referenced Secret changes.
      "reloader.stakater.com/auto" = "true"
    }
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
          # The greeting shown at "/" comes from the OpenBao-synced secret.
          env {
            name = "PODINFO_UI_MESSAGE"
            value_from {
              secret_key_ref {
                name     = "podinfo-config"
                key      = "greeting"
                optional = true
              }
            }
          }
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
    namespace = kubernetes_namespace.tenant.metadata[0].name
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
