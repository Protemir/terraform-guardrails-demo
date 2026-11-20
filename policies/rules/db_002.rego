package rules.db_002

import rego.v1

import data.lib.iac

meta := {
	"id": "DB-002",
	"severity": "medium",
	"class": "Резервное копирование",
	"title": "База данных без защиты от удаления",
	"description": "Ошибочный destroy или замена ресурса удалит базу вместе с данными.",
	"fix": "deletion_protection = true (AWS, GCP).",
}

findings contains f if {
	some r in iac.of_types({"aws_db_instance", "aws_rds_cluster", "google_sql_database_instance"})
	not iac.val(r.values, "deletion_protection", r.type == "google_sql_database_instance") == true
	f := {"address": r.address, "attr": "deletion_protection", "msg": "deletion_protection выключен"}
}
