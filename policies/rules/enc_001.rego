package rules.enc_001

import rego.v1

import data.lib.iac

meta := {
	"id": "ENC-001",
	"severity": "high",
	"class": "Шифрование",
	"title": "Ingress без TLS",
	"description": "Ingress без блока tls отдаёт приложение по открытому HTTP.",
	"fix": "Добавьте блок tls и аннотацию cert-manager.io/cluster-issuer (модуль ingress создаёт issuer).",
}

findings contains f if {
	some r in iac.of_types({"kubernetes_ingress_v1", "kubernetes_ingress"})
	spec := iac.block(r.values, "spec")
	count(iac.arr(spec, "tls")) == 0
	f := {"address": r.address, "attr": "spec", "msg": "нет блока tls — трафик идёт по HTTP"}
}
