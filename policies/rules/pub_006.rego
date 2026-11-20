package rules.pub_006

import rego.v1

import data.lib.iac

meta := {
	"id": "PUB-006",
	"severity": "critical",
	"class": "Публичный доступ",
	"title": "Публично доступная управляемая база данных",
	"description": "База получает публичный адрес (publicly_accessible, public_network_access_enabled) или пускает 0.0.0.0/0.",
	"fix": "Отключите публичный доступ, подключайтесь из приватной сети.",
}

findings contains f if {
	some r in iac.of_types({"aws_db_instance", "aws_rds_cluster_instance", "aws_redshift_cluster", "aws_dms_replication_instance"})
	iac.val(r.values, "publicly_accessible", false) == true
	f := {"address": r.address, "attr": "publicly_accessible", "msg": "publicly_accessible = true"}
}

findings contains f if {
	some r in iac.of_types({"azurerm_postgresql_flexible_server", "azurerm_mssql_server", "azurerm_mysql_flexible_server", "azurerm_postgresql_server", "azurerm_mysql_server"})
	iac.val(r.values, "public_network_access_enabled", false) == true
	f := {"address": r.address, "attr": "public_network_access_enabled", "msg": "public_network_access_enabled = true"}
}

findings contains f if {
	some r in iac.of_type("google_sql_database_instance")
	s := iac.block(r.values, "settings")
	ip := iac.block(s, "ip_configuration")
	some n in iac.arr(ip, "authorized_networks")
	iac.cidr_open(iac.val(n, "value", ""))
	f := {"address": r.address, "attr": "authorized_networks", "msg": "authorized_networks содержит 0.0.0.0/0"}
}
