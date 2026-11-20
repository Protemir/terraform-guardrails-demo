package rules.enc_006

import rego.v1

import data.lib.iac

meta := {
	"id": "ENC-006",
	"severity": "high",
	"class": "Шифрование",
	"title": "Cloud SQL без обязательного SSL",
	"description": "Экземпляр Cloud SQL принимает незашифрованные подключения.",
	"fix": "settings.ip_configuration.ssl_mode = ENCRYPTED_ONLY (или require_ssl = true).",
}

findings contains f if {
	some r in iac.of_type("google_sql_database_instance")
	ip := iac.block(iac.block(r.values, "settings"), "ip_configuration")
	not ssl_required(ip)
	f := {"address": r.address, "attr": "ip_configuration", "msg": "подключения без SSL разрешены"}
}

ssl_required(ip) if iac.val(ip, "require_ssl", false) == true

ssl_required(ip) if iac.val(ip, "ssl_mode", "") in {"ENCRYPTED_ONLY", "TRUSTED_CLIENT_CERTIFICATE_REQUIRED"}
