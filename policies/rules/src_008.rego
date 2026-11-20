package rules.src_008

import rego.v1

import data.lib.iac

meta := {
	"id": "SRC-008",
	"severity": "high",
	"class": "Версии и источники модулей",
	"title": "Провайдер без ограничения версии",
	"description": "Без version в required_providers новая мажорная версия провайдера может прийти при следующем init и сломать план.",
	"fix": "required_providers { kubernetes = { source = \"hashicorp/kubernetes\", version = \"~> 3.5\" } } и .terraform.lock.hcl в репозитории.",
}

findings contains f if {
	some p in iac.providers
	trim_space(p.version) == ""
	f := {"address": sprintf("provider.%s", [p.name]), "attr": "required_providers", "msg": sprintf("провайдер %s без ограничения версии", [p.name])}
}
