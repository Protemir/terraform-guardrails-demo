package rules.src_003

import rego.v1

import data.lib.iac

meta := {
	"id": "SRC-003",
	"severity": "high",
	"class": "Версии и источники модулей",
	"title": "Модуль реестра без точной версии",
	"description": "Диапазон версий (~>, >=) или её отсутствие означает, что новая версия модуля придёт без ревью.",
	"fix": "version = \"5.8.1\" и обновление через PR (например, Renovate).",
}

findings contains f if {
	some m in iac.module_calls
	registry(m.source)
	not regex.match("^=? ?v?[0-9]+[.][0-9]+[.][0-9]+$", trim_space(m.version))
	f := {"address": sprintf("module.%s", [m.name]), "attr": "version", "msg": sprintf("version %q — нужна точная версия", [m.version])}
}

registry(s) if {
	not contains(s, "::")
	not startswith(s, ".")
	not startswith(s, "github.com/")
	not startswith(s, "bitbucket.org/")
	not startswith(s, "git@")
	parts := split(trim_prefix(s, "registry.terraform.io/"), "/")
	count(parts) == 3
}
