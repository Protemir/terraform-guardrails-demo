package rules.src_002

import rego.v1

import data.lib.iac

meta := {
	"id": "SRC-002",
	"severity": "critical",
	"class": "Версии и источники модулей",
	"title": "Модуль из непроверенного источника",
	"description": "Разрешены только локальные модули библиотеки, модули реестра из одобренных пространств имён и git-репозитории из списка.",
	"fix": "Используйте модуль библиотеки или добавьте источник в policies/config.yaml через ревью команды платформы.",
}

default_namespaces := ["terraform-aws-modules", "Azure", "terraform-google-modules", "Protemir"]

default_git := ["git::https://github.com/Protemir/"]

namespaces := object.get(iac.config, "registry_namespaces", default_namespaces)

git_prefixes := object.get(iac.config, "git_prefixes", default_git)

findings contains f if {
	some m in iac.module_calls
	not allowed(m.source)
	f := {"address": sprintf("module.%s", [m.name]), "attr": "source", "msg": sprintf("источник %q не входит в список разрешённых", [m.source])}
}

allowed(s) if startswith(s, "./")

allowed(s) if startswith(s, "../")

allowed(s) if {
	some p in git_prefixes
	startswith(s, p)
}

allowed(s) if {
	parts := registry_parts(s)
	parts[0] in namespaces
}

registry_parts(s) := parts if {
	not contains(s, "::")
	not contains(s, "//")
	parts := split(trim_prefix(s, "registry.terraform.io/"), "/")
	count(parts) == 3
}
