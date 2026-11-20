terraform {
  required_version = ">= 1.11.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.3"
    }
  }
}

provider "helm" {
  kubernetes = {
    config_path    = "~/.kube/config"
    config_context = "kind-stand"
  }
}

module "ingress" {
  source = "../.."

  service_type = "NodePort"
  replicas     = 1
}

output "cluster_issuer" {
  description = "ClusterIssuer для аннотации Ingress."
  value       = module.ingress.cluster_issuer
}
