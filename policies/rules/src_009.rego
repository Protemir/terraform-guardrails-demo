package rules.src_009

import rego.v1

import data.lib.iac

meta := {
	"id": "SRC-009",
	"severity": "high",
	"class": "Версии и источники модулей",
	"title": "Запрещённая (снятая с поддержки) версия движка",
	"description": "PostgreSQL ниже 14, MySQL ниже 8.0, Kubernetes ниже 1.32 больше не получают исправлений безопасности.",
	"fix": "Поднимите версию; минимальные значения — в min_versions (policies/config.yaml).",
}

default_min := {"postgres": 14, "mysql": 8, "kubernetes": 132}

mins := object.get(iac.config, "min_versions", default_min)

findings contains f if {
	some r in iac.of_types({"aws_db_instance", "aws_rds_cluster"})
	engine := engine_family(iac.val(r.values, "engine", ""))
	v := iac.val(r.values, "engine_version", "")
	is_string(v)
	v != ""
	not contains(v, "${")
	major(v) < mins[engine]
	f := {"address": r.address, "attr": "engine_version", "msg": sprintf("%s %s снят с поддержки", [engine, v])}
}

findings contains f if {
	some r in iac.of_type("google_sql_database_instance")
	v := iac.val(r.values, "database_version", "")
	startswith(v, "POSTGRES_")
	to_number(trim_prefix(v, "POSTGRES_")) < mins.postgres
	f := {"address": r.address, "attr": "database_version", "msg": sprintf("%s снят с поддержки", [v])}
}

findings contains f if {
	some r in iac.of_type("google_sql_database_instance")
	v := iac.val(r.values, "database_version", "")
	startswith(v, "MYSQL_5")
	f := {"address": r.address, "attr": "database_version", "msg": sprintf("%s снят с поддержки", [v])}
}

findings contains f if {
	some r in iac.of_types({"aws_eks_cluster", "azurerm_kubernetes_cluster", "google_container_cluster"})
	some attr in ["version", "kubernetes_version", "min_master_version"]
	v := iac.val(r.values, attr, "")
	is_string(v)
	regex.match("^[0-9]+[.][0-9]+", v)
	parts := split(v, ".")
	(to_number(parts[0]) * 100) + to_number(parts[1]) < mins.kubernetes
	f := {"address": r.address, "attr": attr, "msg": sprintf("Kubernetes %s снят с поддержки", [v])}
}

engine_family(e) := "postgres" if contains(e, "postgres")

engine_family(e) := "mysql" if e in {"mysql", "aurora-mysql", "mariadb"}

major(v) := to_number(split(v, ".")[0])
