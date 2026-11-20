package rules.log_003

import rego.v1

import data.lib.iac

meta := {
	"id": "LOG-003",
	"severity": "medium",
	"class": "Журналирование",
	"title": "Управляемый Kubernetes без журналов control plane",
	"description": "Журналы API-сервера и аудита кластера не собираются.",
	"fix": "EKS: enabled_cluster_log_types с api и audit; GKE: logging_service не none; AKS: oms_agent.",
}

findings contains f if {
	some r in iac.of_type("aws_eks_cluster")
	types := iac.arr(r.values, "enabled_cluster_log_types")
	some need in ["api", "audit"]
	not need in types
	f := {"address": r.address, "attr": "enabled_cluster_log_types", "msg": sprintf("не включён журнал %s", [need])}
}

findings contains f if {
	some r in iac.of_type("google_container_cluster")
	some attr in ["logging_service", "monitoring_service"]
	iac.val(r.values, attr, "") == "none"
	f := {"address": r.address, "attr": attr, "msg": sprintf("%s = none", [attr])}
}

findings contains f if {
	some r in iac.of_type("azurerm_kubernetes_cluster")
	count(iac.arr(r.values, "oms_agent")) == 0
	count(iac.arr(r.values, "microsoft_defender")) == 0
	f := {"address": r.address, "attr": "oms_agent", "msg": "мониторинг журналов кластера не подключён"}
}
