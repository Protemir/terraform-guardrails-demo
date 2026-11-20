package rules.src_007

import rego.v1

import data.lib.iac

meta := {
	"id": "SRC-007",
	"severity": "medium",
	"class": "Версии и источники модулей",
	"title": "Образ из реестра вне списка",
	"description": "Образы берутся только из одобренных реестров: их проверяет сканер и они доступны с площадки.",
	"fix": "Перенесите образ в разрешённый реестр или добавьте реестр в image_registries (policies/config.yaml).",
}

default_registries := [
	"registry.k8s.io/",
	"ghcr.io/",
	"quay.io/",
	"cgr.dev/",
	"docker.io/library/",
	"mirror.gcr.io/",
]

registries := object.get(iac.config, "image_registries", default_registries)

findings contains f if {
	some x in iac.containers
	img := iac.val(x.c, "image", "")
	is_string(img)
	img != ""
	not contains(img, "${")
	full := normalize(img)
	not trusted(full)
	f := {"address": x.address, "attr": "image", "msg": sprintf("контейнер %s: реестр образа %q не разрешён", [iac.container_name(x.c), full])}
}

normalize(img) := sprintf("docker.io/library/%s", [img]) if not contains(img, "/")

normalize(img) := img if {
	contains(img, "/")
	first := split(img, "/")[0]
	registry_host(first)
}

normalize(img) := sprintf("docker.io/%s", [img]) if {
	contains(img, "/")
	first := split(img, "/")[0]
	not registry_host(first)
}

registry_host(s) if contains(s, ".")

registry_host(s) if contains(s, ":")

registry_host("localhost")

trusted(full) if {
	some p in registries
	startswith(full, p)
}
