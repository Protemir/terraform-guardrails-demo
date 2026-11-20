# Юнит-тесты общего слоя и точки входа на JSON-плане (conftest verify -p policies).
package main_test

import rego.v1

import data.lib.iac
import data.main

plan := {
	"resource_changes": [
		{
			"address": "kubernetes_service_v1.lb",
			"mode": "managed",
			"type": "kubernetes_service_v1",
			"name": "lb",
			"change": {"actions": ["create"], "after": {"metadata": [{"name": "web", "annotations": null}], "spec": [{"type": "LoadBalancer", "load_balancer_source_ranges": null}]}, "after_unknown": {}},
		},
		{
			"address": "kubernetes_service_v1.old",
			"mode": "managed",
			"type": "kubernetes_service_v1",
			"name": "old",
			"change": {"actions": ["delete"], "after": null},
		},
		{
			"address": "data.kubernetes_namespace_v1.x",
			"mode": "data",
			"type": "kubernetes_namespace_v1",
			"name": "x",
			"change": {"actions": ["read"], "after": {}},
		},
		{
			"address": "kubernetes_service_v1.np",
			"mode": "managed",
			"type": "kubernetes_service_v1",
			"name": "np",
			"change": {"actions": ["update"], "after": {"metadata": [{"name": "np"}], "spec": [{"type": "NodePort"}]}},
		},
	],
	"configuration": {
		"provider_config": {"kubernetes": {"name": "kubernetes", "full_name": "registry.terraform.io/hashicorp/kubernetes", "version_constraint": "~> 3.5"}},
		"root_module": {"module_calls": {
			"app": {"source": "../../modules/app-namespace", "module": {"module_calls": {"inner": {"source": "git::https://example.com/x.git"}}}},
			"vpc": {"source": "terraform-aws-modules/vpc/aws", "version_constraint": "~> 6.0"},
		}},
	},
}

test_plan_skips_deletes_and_data_sources if {
	addrs := {r.address | some r in iac.resources} with input as plan
	addrs == {"kubernetes_service_v1.lb", "kubernetes_service_v1.np"}
}

test_module_calls_include_nested if {
	names := {m.name | some m in iac.module_calls} with input as plan
	names == {"app", "inner", "vpc"}
}

test_providers_from_plan if {
	ps := iac.providers with input as plan
	ps == {{"name": "registry.terraform.io/hashicorp/kubernetes", "version": "~> 3.5"}}
}

test_null_values_are_safe if {
	iac.arr({"a": null}, "a") == []
	iac.val({"a": null}, "a", 7) == 7
	iac.block({"a": null}, "a") == {}
}

test_critical_goes_to_deny if {
	ids := {d.rule | some d in main.deny} with input as plan
	"PUB-001" in ids
	"SRC-001" in ids
	not "PUB-002" in ids
}

test_high_goes_to_warn if {
	ids := {w.rule | some w in main.warn} with input as plan
	"PUB-002" in ids
	"SRC-003" in ids
}

test_valid_exception_suppresses if {
	exc := [{"rule": "PUB-001", "resource": "kubernetes_service_v1.*", "reason": "Временный внешний адрес для демо заказчику", "owner": "team-shop", "expires": "2026-12-31"}]
	ids := {d.rule | some d in main.deny} with input as plan with data.exceptions as exc with time.now_ns as time.parse_rfc3339_ns("2026-11-20T00:00:00Z")
	not "PUB-001" in ids
}

test_expired_exception_does_not_suppress if {
	exc := [{"rule": "PUB-001", "resource": "kubernetes_service_v1.*", "reason": "Временный внешний адрес для демо заказчику", "owner": "team-shop", "expires": "2026-01-31"}]
	ids := {d.rule | some d in main.deny} with input as plan with data.exceptions as exc with time.now_ns as time.parse_rfc3339_ns("2026-11-20T00:00:00Z")
	"PUB-001" in ids
}

test_exception_without_reason_blocks if {
	exc := [{"rule": "PUB-001", "resource": "kubernetes_service_v1.*", "reason": "надо", "owner": "team-shop", "expires": "2026-12-31"}]
	ids := {d.rule | some d in main.deny} with input as plan with data.exceptions as exc with time.now_ns as time.parse_rfc3339_ns("2026-11-20T00:00:00Z")
	"PUB-001" in ids
	"EXC-001" in ids
}

test_every_rule_has_metadata if {
	every _, rule in data.rules {
		regex.match("^[A-Z]{2,4}-[0-9]{3}$", rule.meta.id)
		rule.meta.severity in {"critical", "high", "medium", "low"}
		count(rule.meta.title) > 0
		count(rule.meta.description) > 0
		count(rule.meta.fix) > 0
		count(rule.meta.class) > 0
	}
}

test_at_least_30_rules if {
	count(data.rules) >= 30
}
