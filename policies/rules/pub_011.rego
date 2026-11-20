package rules.pub_011

import rego.v1

import data.lib.iac

meta := {
	"id": "PUB-011",
	"severity": "critical",
	"class": "Публичный доступ",
	"title": "API управляемого Kubernetes открыт всему интернету",
	"description": "Публичная точка API-сервера кластера (EKS, AKS, GKE) без ограничения адресов доступна для подбора учётных данных и эксплуатации уязвимостей.",
	"fix": "Закройте публичную точку или ограничьте её адресами VPN/офиса: EKS — endpoint_public_access = false или public_access_cidrs; AKS — authorized_ip_ranges; GKE — master_authorized_networks_config.",
}

findings contains f if {
	some r in iac.of_type("aws_eks_cluster")
	vpc := iac.block(r.values, "vpc_config")

	# По умолчанию AWS включает публичную точку; выражение HCL — значение неизвестно, пропускаем.
	iac.val(vpc, "endpoint_public_access", true) == true
	cidrs := object.get(vpc, "public_access_cidrs", null)
	open_cidrs(cidrs)
	f := {"address": r.address, "attr": "endpoint_public_access", "msg": "публичная точка API EKS открыта для 0.0.0.0/0"}
}

findings contains f if {
	some r in iac.of_type("azurerm_kubernetes_cluster")
	not iac.val(r.values, "private_cluster_enabled", false) == true
	profile := iac.block(r.values, "api_server_access_profile")
	count(iac.arr(profile, "authorized_ip_ranges")) == 0
	count(iac.arr(r.values, "api_server_authorized_ip_ranges")) == 0
	f := {"address": r.address, "attr": "api_server_access_profile", "msg": "API AKS доступен из любой сети"}
}

findings contains f if {
	some r in iac.of_type("google_container_cluster")
	not private_endpoint(r.values)
	count(iac.arr(r.values, "master_authorized_networks_config")) == 0
	f := {"address": r.address, "attr": "master_authorized_networks_config", "msg": "API GKE доступен из любой сети"}
}

open_cidrs(null)

open_cidrs(cidrs) if {
	is_array(cidrs)
	some c in cidrs
	iac.cidr_open(c)
}

private_endpoint(v) if iac.val(iac.block(v, "private_cluster_config"), "enable_private_endpoint", false) == true
