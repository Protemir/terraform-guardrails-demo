package rules.enc_005

import rego.v1

import data.lib.iac

meta := {
	"id": "ENC-005",
	"severity": "high",
	"class": "Шифрование",
	"title": "Хранилище Azure допускает HTTP или старый TLS",
	"description": "Учётная запись хранения принимает запросы по HTTP или по TLS ниже 1.2.",
	"fix": "https_traffic_only_enabled = true, min_tls_version = TLS1_2.",
}

findings contains f if {
	some r in iac.of_type("azurerm_storage_account")
	some attr in ["https_traffic_only_enabled", "enable_https_traffic_only"]
	iac.val(r.values, attr, true) == false
	f := {"address": r.address, "attr": attr, "msg": "разрешён HTTP"}
}

findings contains f if {
	some r in iac.of_types({"azurerm_storage_account", "azurerm_mssql_server", "azurerm_postgresql_server", "azurerm_mysql_server", "azurerm_redis_cache"})
	some attr in ["min_tls_version", "minimum_tls_version", "ssl_minimal_tls_version_enforced"]
	v := iac.val(r.values, attr, "")
	v in {"TLS1_0", "TLS1_1", "1.0", "1.1"}
	f := {"address": r.address, "attr": attr, "msg": sprintf("%s = %s", [attr, v])}
}

findings contains f if {
	some r in iac.of_types({"azurerm_postgresql_server", "azurerm_mysql_server"})
	iac.val(r.values, "ssl_enforcement_enabled", true) == false
	f := {"address": r.address, "attr": "ssl_enforcement_enabled", "msg": "SSL не обязателен"}
}
