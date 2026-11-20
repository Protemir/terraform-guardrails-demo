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

module "secrets" {
  source = "../.."

  sealed_secrets = {
    "shop-api" = {
      namespace      = "shop-dev"
      encrypted_data = { API_TOKEN = "AgBy3i4OJSWK+PiTySYZZA9rO43cGDEq0P1Ri9rBAP0TfTuu0kLHfB0J7wiEo0PcZqLnFxsxKqJ1kyBP7b5YpNe6sjqb1Wq7" }
      labels         = { owner = "team-shop" }
    }
  }
}

output "seal_command" {
  description = "Как получить шифртекст."
  value       = module.secrets.seal_command
}
