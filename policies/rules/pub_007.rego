package rules.pub_007

import rego.v1

import data.lib.iac

meta := {
	"id": "PUB-007",
	"severity": "critical",
	"class": "Публичный доступ",
	"title": "Правило NSG Azure пускает интернет на админ-порты",
	"description": "Входящее Allow-правило с источником *, Internet или 0.0.0.0/0 на SSH, RDP, порты БД или на любой порт.",
	"fix": "Ограничьте source_address_prefix адресами VPN или бастиона.",
}

rules_of(r) := [r.values] if r.type == "azurerm_network_security_rule"

rules_of(r) := iac.arr(r.values, "security_rule") if r.type == "azurerm_network_security_group"

findings contains f if {
	some r in iac.of_types({"azurerm_network_security_rule", "azurerm_network_security_group"})
	some rule in rules_of(r)
	lower(iac.val(rule, "direction", "")) == "inbound"
	lower(iac.val(rule, "access", "")) == "allow"
	some s in array.concat([iac.val(rule, "source_address_prefix", "")], iac.arr(rule, "source_address_prefixes"))
	iac.cidr_open(s)
	risky_port(rule)
	f := {"address": r.address, "attr": "source_address_prefix", "msg": sprintf("правило %v открыто из интернета", [iac.val(rule, "name", "?")])}
}

risky_port(rule) if {
	some p in array.concat([iac.val(rule, "destination_port_range", "")], iac.arr(rule, "destination_port_ranges"))
	port_hits(sprintf("%v", [p]))
}

port_hits("*")

port_hits(p) if {
	not contains(p, "-")
	not p in {"", "*"}
	to_number(p) in iac.admin_ports
}

port_hits(p) if {
	parts := split(p, "-")
	count(parts) == 2
	iac.ports_risky(parts[0], parts[1])
}
