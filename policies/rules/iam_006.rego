package rules.iam_006

import rego.v1

import data.lib.iac

meta := {
	"id": "IAM-006",
	"severity": "medium",
	"class": "Избыточные права",
	"title": "Контейнер может работать от root",
	"description": "Не задан run_as_non_root = true. Особенность провайдера kubernetes: если у контейнера есть блок security_context, провайдер отправляет runAsNonRoot = false, и это перекрывает настройку пода — поэтому значение проверяется на уровне контейнера.",
	"fix": "security_context { run_as_non_root = true } у пода и в каждом security_context контейнера.",
}

# Блока security_context у контейнера нет — действует настройка пода.
findings contains f if {
	some x in iac.containers
	count(iac.csc(x.c)) == 0
	not iac.val(iac.podsc(x.pod), "run_as_non_root", false) == true
	f := {"address": x.address, "attr": "run_as_non_root", "msg": sprintf("контейнер %s: не запрещён запуск от root", [iac.container_name(x.c)])}
}

# Блок есть — провайдер отправит значение контейнера (по умолчанию false), оно перекрывает под.
findings contains f if {
	some x in iac.containers
	count(iac.csc(x.c)) > 0
	not iac.val(iac.csc(x.c), "run_as_non_root", false) == true
	f := {"address": x.address, "attr": "run_as_non_root", "msg": sprintf("контейнер %s: security_context без run_as_non_root = true — перекрывает настройку пода, запуск от root не запрещён", [iac.container_name(x.c)])}
}
