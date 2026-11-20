package rules.pub_005

import rego.v1

import data.lib.iac

meta := {
	"id": "PUB-005",
	"severity": "critical",
	"class": "Публичный доступ",
	"title": "Security group открывает админ-порты или все порты всему интернету",
	"description": "Входящее правило из 0.0.0.0/0 или ::/0 на SSH, RDP, порты баз данных или на весь диапазон портов.",
	"fix": "Ограничьте источник адресами VPN или бастиона.",
}

findings contains f if {
	some r in iac.of_type("aws_security_group")
	some rule in iac.arr(r.values, "ingress")
	open_rule(rule)
	f := {"address": r.address, "attr": "cidr_blocks", "msg": sprintf("ingress %v-%v открыт из интернета", [rule.from_port, rule.to_port])}
}

findings contains f if {
	some r in iac.of_type("aws_security_group_rule")
	r.values.type == "ingress"
	open_rule(r.values)
	f := {"address": r.address, "attr": "cidr_blocks", "msg": sprintf("ingress %v-%v открыт из интернета", [r.values.from_port, r.values.to_port])}
}

findings contains f if {
	some r in iac.of_type("aws_vpc_security_group_ingress_rule")
	some c in [iac.val(r.values, "cidr_ipv4", ""), iac.val(r.values, "cidr_ipv6", "")]
	iac.cidr_open(c)
	iac.ports_risky(iac.val(r.values, "from_port", -1), iac.val(r.values, "to_port", -1))
	f := {"address": r.address, "attr": "cidr_ipv4", "msg": "правило открыто из интернета на опасные порты"}
}

open_rule(rule) if {
	some c in array.concat(iac.arr(rule, "cidr_blocks"), iac.arr(rule, "ipv6_cidr_blocks"))
	iac.cidr_open(c)
	iac.ports_risky(iac.val(rule, "from_port", 0), iac.val(rule, "to_port", 0))
}
