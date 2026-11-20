package rules.src_010

import rego.v1

import data.lib.iac

meta := {
	"id": "SRC-010",
	"severity": "critical",
	"class": "Версии и источники модулей",
	"title": "Удалённый API Kubernetes или устаревший тип ресурса",
	"description": "apiVersion, которого больше нет в кластере (extensions/v1beta1, policy/v1beta1 и т.п.), или ресурс провайдера без суффикса _v1, который не поддерживается.",
	"fix": "Перейдите на актуальную apiVersion и ресурсы *_v1 провайдера kubernetes.",
}

removed_apis := {
	"extensions/v1beta1", "apps/v1beta1", "apps/v1beta2", "policy/v1beta1",
	"batch/v1beta1", "networking.k8s.io/v1beta1", "rbac.authorization.k8s.io/v1beta1",
	"autoscaling/v2beta1", "autoscaling/v2beta2", "storage.k8s.io/v1beta1",
	"admissionregistration.k8s.io/v1beta1", "flowcontrol.apiserver.k8s.io/v1beta3",
}

findings contains f if {
	some r in iac.of_type("kubernetes_manifest")
	m := iac.obj(r.values, "manifest")
	m.apiVersion in removed_apis
	f := {"address": r.address, "attr": "apiVersion", "msg": sprintf("apiVersion %s удалён из Kubernetes", [m.apiVersion])}
}

findings contains f if {
	some r in iac.resources
	r.type in {"kubernetes_pod_security_policy", "kubernetes_pod_security_policy_v1beta1"}
	f := {"address": r.address, "attr": "metadata", "msg": "PodSecurityPolicy удалён в Kubernetes 1.25"}
}
