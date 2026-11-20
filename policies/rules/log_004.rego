package rules.log_004

import rego.v1

import data.lib.iac

meta := {
	"id": "LOG-004",
	"severity": "medium",
	"class": "Журналирование",
	"title": "Балансировщик или сеть без журнала",
	"description": "Нет журнала доступа балансировщика или журнала сетевых потоков подсети — разбор инцидента невозможен.",
	"fix": "aws_lb: access_logs { enabled = true }; google_compute_subnetwork: log_config.",
}

findings contains f if {
	some r in iac.of_types({"aws_lb", "aws_alb"})
	iac.val(r.values, "load_balancer_type", "application") == "application"
	logs := iac.block(r.values, "access_logs")
	not iac.val(logs, "enabled", false) == true
	f := {"address": r.address, "attr": "access_logs", "msg": "журнал доступа балансировщика выключен"}
}

findings contains f if {
	some r in iac.of_type("google_compute_subnetwork")
	count(iac.arr(r.values, "log_config")) == 0
	f := {"address": r.address, "attr": "log_config", "msg": "журнал потоков VPC выключен"}
}
