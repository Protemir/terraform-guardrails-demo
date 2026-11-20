package rules.pub_001

import rego.v1

import data.lib.iac

meta := {
	"id": "PUB-001",
	"severity": "critical",
	"class": "Публичный доступ",
	"title": "Service типа LoadBalancer открыт в интернет",
	"description": "Сервис LoadBalancer без load_balancer_source_ranges и без аннотации внутреннего балансировщика получает внешний адрес, доступный всем.",
	"fix": "Публикуйте приложение через Ingress (модуль ingress) или задайте load_balancer_source_ranges / аннотацию internal.",
}

internal_annotations := {
	"service.beta.kubernetes.io/aws-load-balancer-internal",
	"service.beta.kubernetes.io/azure-load-balancer-internal",
	"networking.gke.io/load-balancer-type",
	"cloud.google.com/load-balancer-type",
}

findings contains f if {
	some r in iac.of_types({"kubernetes_service_v1", "kubernetes_service"})
	spec := iac.block(r.values, "spec")
	spec.type == "LoadBalancer"
	count(iac.arr(spec, "load_balancer_source_ranges")) == 0
	ann := iac.obj(iac.metadata(r), "annotations")
	not has_internal(ann)
	f := {"address": r.address, "attr": "type", "msg": "type = LoadBalancer без ограничения источников: сервис получит публичный адрес"}
}

has_internal(ann) if {
	some k, _ in ann
	k in internal_annotations
}

has_internal(ann) if ann["service.beta.kubernetes.io/aws-load-balancer-scheme"] == "internal"
