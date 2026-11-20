package rules.src_001

import rego.v1

import data.lib.iac

meta := {
	"id": "SRC-001",
	"severity": "critical",
	"class": "Версии и источники модулей",
	"title": "Модуль из git или по ссылке без закреплённой версии",
	"description": "Источник без ?ref=<тег или SHA> подтягивает то, что сейчас лежит в ветке по умолчанию: код может поменяться без ревью.",
	"fix": "source = \"git::https://github.com/org/repo.git//path?ref=v1.2.3\" или полный SHA коммита.",
}

findings contains f if {
	some m in iac.module_calls
	remote_vcs(m.source)
	not pinned(m.source)
	f := {"address": sprintf("module.%s", [m.name]), "attr": "source", "msg": sprintf("source %q без ref на тег или коммит", [m.source])}
}

findings contains f if {
	some m in iac.module_calls
	regex.match("^(https?|s3|gcs)::?", m.source)
	not regex.match("[0-9]+[.][0-9]+[.][0-9]+", m.source)
	f := {"address": sprintf("module.%s", [m.name]), "attr": "source", "msg": sprintf("архив %q без версии в пути", [m.source])}
}

remote_vcs(s) if startswith(s, "git::")

remote_vcs(s) if startswith(s, "git@")

remote_vcs(s) if startswith(s, "hg::")

remote_vcs(s) if startswith(s, "github.com/")

remote_vcs(s) if startswith(s, "bitbucket.org/")

pinned(s) if regex.match("[?&]ref=v?[0-9]+[.][0-9]+[.][0-9]+([-+][0-9A-Za-z.-]+)?($|&)", s)

pinned(s) if regex.match("[?&]ref=[0-9a-f]{40}($|&)", s)
