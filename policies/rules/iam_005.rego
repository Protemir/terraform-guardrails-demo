package rules.iam_005

import rego.v1

import data.lib.iac

meta := {
	"id": "IAM-005",
	"severity": "high",
	"class": "Избыточные права",
	"title": "Опасные Linux capabilities",
	"description": "SYS_ADMIN, NET_ADMIN, SYS_PTRACE, NET_RAW или ALL почти равны root на узле.",
	"fix": "capabilities { drop = [\"ALL\"] } и добавляйте только безопасные (например NET_BIND_SERVICE).",
}

dangerous := {"ALL", "SYS_ADMIN", "NET_ADMIN", "SYS_PTRACE", "SYS_MODULE", "NET_RAW", "DAC_READ_SEARCH", "BPF"}

findings contains f if {
	some x in iac.containers
	caps := iac.block(iac.csc(x.c), "capabilities")
	some c in iac.arr(caps, "add")
	upper(c) in dangerous
	f := {"address": x.address, "attr": "add", "msg": sprintf("контейнер %s добавляет capability %s", [iac.container_name(x.c), c])}
}
