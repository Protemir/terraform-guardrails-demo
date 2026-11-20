package rules.pub_002

import rego.v1

import data.lib.iac

meta := {
	"id": "PUB-002",
	"severity": "high",
	"class": "Публичный доступ",
	"title": "Service типа NodePort",
	"description": "NodePort открывает порт на каждом узле кластера в обход Ingress.",
	"fix": "Используйте ClusterIP и Ingress.",
}

findings contains f if {
	some r in iac.of_types({"kubernetes_service_v1", "kubernetes_service"})
	spec := iac.block(r.values, "spec")
	spec.type == "NodePort"
	f := {"address": r.address, "attr": "type", "msg": "type = NodePort открывает порт на всех узлах"}
}
