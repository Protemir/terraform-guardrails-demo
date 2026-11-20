package rules.enc_002

import rego.v1

import data.lib.iac

meta := {
	"id": "ENC-002",
	"severity": "high",
	"class": "Шифрование",
	"title": "Секрет Kubernetes открытым текстом в коде Terraform",
	"description": "kubernetes_secret_v1 с data хранит значение в коде и в состоянии Terraform без шифрования.",
	"fix": "Используйте модуль secrets (SealedSecret): в репозиторий попадает только зашифрованное значение.",
}

findings contains f if {
	some r in iac.of_types({"kubernetes_secret_v1", "kubernetes_secret"})
	some attr in ["data", "binary_data"]
	d := object.get(r.values, attr, null)
	d != null
	not empty_object(d)
	not iac.val(r.values, "type", "") == "kubernetes.io/service-account-token"
	f := {"address": r.address, "attr": attr, "msg": "значение секрета лежит в коде и в состоянии Terraform"}
}

empty_object(d) if {
	is_object(d)
	count(d) == 0
}
