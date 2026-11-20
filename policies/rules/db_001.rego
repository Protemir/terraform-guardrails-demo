package rules.db_001

import rego.v1

import data.lib.iac

meta := {
	"id": "DB-001",
	"severity": "high",
	"class": "Резервное копирование",
	"title": "База данных без резервных копий",
	"description": "Резервное копирование выключено или хранится меньше 7 дней.",
	"fix": "AWS: backup_retention_period >= 7; GCP: backup_configuration.enabled; модуль postgres-cnpg: backup.enabled = true.",
}

findings contains f if {
	some r in iac.of_types({"aws_db_instance", "aws_rds_cluster"})
	not r.unknown.backup_retention_period == true
	v := iac.val(r.values, "backup_retention_period", 0)
	is_number(v)
	v < 7
	f := {"address": r.address, "attr": "backup_retention_period", "msg": sprintf("backup_retention_period = %v (нужно >= 7)", [v])}
}

findings contains f if {
	some r in iac.of_type("google_sql_database_instance")
	b := iac.block(iac.block(r.values, "settings"), "backup_configuration")
	not iac.val(b, "enabled", false) == true
	f := {"address": r.address, "attr": "backup_configuration", "msg": "резервное копирование выключено"}
}

# Кластер CloudNativePG из модуля postgres-cnpg: значения чарта в YAML.
findings contains f if {
	some r in iac.of_type("helm_release")
	endswith(iac.val(r.values, "chart", ""), "cnpg-cluster")
	some raw in iac.arr(r.values, "values")
	is_string(raw)
	not contains(raw, "${")
	vals := yaml.unmarshal(raw)
	not object.get(vals, ["backup", "enabled"], false) == true
	f := {"address": r.address, "attr": "backup", "msg": "кластер PostgreSQL без резервного копирования в объектное хранилище"}
}
