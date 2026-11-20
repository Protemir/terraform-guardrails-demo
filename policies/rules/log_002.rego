package rules.log_002

import rego.v1

import data.lib.iac

meta := {
	"id": "LOG-002",
	"severity": "high",
	"class": "Журналирование",
	"title": "Журнал аудита облака неполный",
	"description": "CloudTrail только в одном регионе или без проверки целостности файлов журнала.",
	"fix": "is_multi_region_trail = true, enable_log_file_validation = true.",
}

findings contains f if {
	some r in iac.of_type("aws_cloudtrail")
	some attr in ["is_multi_region_trail", "enable_log_file_validation"]
	not iac.val(r.values, attr, false) == true
	f := {"address": r.address, "attr": attr, "msg": sprintf("%s не включён", [attr])}
}
