package rules.src_006

import rego.v1

import data.lib.iac

meta := {
	"id": "SRC-006",
	"severity": "high",
	"class": "Версии и источники модулей",
	"title": "Образ контейнера без версии или с тегом latest",
	"description": "latest и образ без тега меняются без ревью; откатиться на «вчерашнюю» версию невозможно.",
	"fix": "Укажите точный тег (nginx:1.29.3) или дайджест (@sha256:...).",
}

findings contains f if {
	some x in iac.containers
	img := iac.val(x.c, "image", "")
	is_string(img)
	not contains(img, "${")
	not contains(img, "@sha256:")
	t := tag(img)
	t in {"", "latest"}
	f := {"address": x.address, "attr": "image", "msg": sprintf("контейнер %s: образ %q без версии", [iac.container_name(x.c), img])}
}

tag(img) := t if {
	parts := split(img, "/")
	last := parts[count(parts) - 1]
	contains(last, ":")
	t := split(last, ":")[1]
} else := ""
