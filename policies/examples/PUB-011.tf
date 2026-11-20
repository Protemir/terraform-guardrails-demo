# Пример для правила PUB-011: ресурсы bad_* нарушают правило, good_* — нет.

resource "aws_eks_cluster" "bad_public_api" {
  name     = "shop"
  role_arn = "arn"
  vpc_config {
    subnet_ids = ["subnet-1", "subnet-2"]
  }
}

resource "azurerm_kubernetes_cluster" "bad_aks_open" {
  name       = "shop"
  dns_prefix = "shop"
}

resource "google_container_cluster" "bad_gke_open" {
  name = "shop"
}

resource "aws_eks_cluster" "good_private_api" {
  name     = "shop"
  role_arn = "arn"
  vpc_config {
    subnet_ids              = ["subnet-1", "subnet-2"]
    endpoint_public_access  = false
    endpoint_private_access = true
  }
}

resource "aws_eks_cluster" "good_office_only" {
  name     = "shop"
  role_arn = "arn"
  vpc_config {
    subnet_ids          = ["subnet-1", "subnet-2"]
    public_access_cidrs = ["203.0.113.0/24"]
  }
}

resource "google_container_cluster" "good_gke_authorized" {
  name = "shop"
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = "203.0.113.0/24"
    }
  }
}
