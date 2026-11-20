package rules.pub_009

import rego.v1

import data.lib.iac

meta := {
	"id": "PUB-009",
	"severity": "critical",
	"class": "Публичный доступ",
	"title": "Firewall GCP пускает интернет на админ-порты",
	"description": "Правило INGRESS из 0.0.0.0/0 на SSH, RDP, порты БД или на все порты.",
	"fix": "Ограничьте source_ranges; для SSH используйте IAP (35.235.240.0/20).",
}

findings contains f if {
	some r in iac.of_type("google_compute_firewall")
	upper(iac.val(r.values, "direction", "INGRESS")) == "INGRESS"
	some s in iac.arr(r.values, "source_ranges")
	iac.cidr_open(s)
	some a in iac.arr(r.values, "allow")
	risky(a)
	f := {"address": r.address, "attr": "source_ranges", "msg": "INGRESS из 0.0.0.0/0 на опасные порты"}
}

risky(a) if lower(iac.val(a, "protocol", "")) == "all"

risky(a) if {
	lower(iac.val(a, "protocol", "")) in {"tcp", "udp"}
	count(iac.arr(a, "ports")) == 0
}

risky(a) if {
	some p in iac.arr(a, "ports")
	ps := sprintf("%v", [p])
	not contains(ps, "-")
	to_number(ps) in iac.admin_ports
}

risky(a) if {
	some p in iac.arr(a, "ports")
	parts := split(sprintf("%v", [p]), "-")
	count(parts) == 2
	iac.ports_risky(parts[0], parts[1])
}
