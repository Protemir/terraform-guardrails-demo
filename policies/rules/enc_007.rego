package rules.enc_007

import rego.v1

import data.lib.iac

meta := {
	"id": "ENC-007",
	"severity": "medium",
	"class": "Шифрование",
	"title": "Ключ KMS без ротации",
	"description": "Симметричный ключ KMS / Key Vault без автоматической ротации.",
	"fix": "enable_key_rotation = true (AWS), rotation_period (GCP), rotation_policy (Azure).",
}

findings contains f if {
	some r in iac.of_type("aws_kms_key")
	iac.val(r.values, "customer_master_key_spec", "SYMMETRIC_DEFAULT") == "SYMMETRIC_DEFAULT"
	not iac.val(r.values, "enable_key_rotation", false) == true
	f := {"address": r.address, "attr": "enable_key_rotation", "msg": "ротация ключа выключена"}
}

findings contains f if {
	some r in iac.of_type("google_kms_crypto_key")
	iac.val(r.values, "rotation_period", "") == ""
	f := {"address": r.address, "attr": "rotation_period", "msg": "не задан rotation_period"}
}
