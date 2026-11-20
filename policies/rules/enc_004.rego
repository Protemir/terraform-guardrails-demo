package rules.enc_004

import rego.v1

import data.lib.iac

meta := {
	"id": "ENC-004",
	"severity": "high",
	"class": "Шифрование",
	"title": "Балансировщик принимает HTTP без перенаправления на HTTPS",
	"description": "Listener по HTTP, который не перенаправляет на HTTPS, отдаёт трафик без шифрования.",
	"fix": "protocol = HTTPS с ssl_policy, а на порту 80 — default_action redirect на HTTPS.",
}

findings contains f if {
	some r in iac.of_types({"aws_lb_listener", "aws_alb_listener"})
	upper(iac.val(r.values, "protocol", "")) == "HTTP"
	not redirects(r.values)
	f := {"address": r.address, "attr": "protocol", "msg": "listener HTTP без redirect на HTTPS"}
}

findings contains f if {
	some r in iac.of_types({"aws_lb_listener", "aws_alb_listener"})
	upper(iac.val(r.values, "protocol", "")) in {"HTTPS", "TLS"}
	p := iac.val(r.values, "ssl_policy", "")
	weak_policy(p)
	f := {"address": r.address, "attr": "ssl_policy", "msg": sprintf("устаревшая ssl_policy %s", [p])}
}

redirects(v) if {
	some a in iac.arr(v, "default_action")
	a.type == "redirect"
}

weak_policy(p) if startswith(p, "ELBSecurityPolicy-2015")

weak_policy(p) if startswith(p, "ELBSecurityPolicy-2016")

weak_policy(p) if contains(p, "TLS-1-0")

weak_policy(p) if contains(p, "TLS-1-1")
