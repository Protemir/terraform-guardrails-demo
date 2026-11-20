package rules.log_001

import rego.v1

import data.lib.iac

meta := {
	"id": "LOG-001",
	"severity": "medium",
	"class": "Журналирование",
	"title": "Бакет S3 без журнала доступа",
	"description": "Без журнала доступа нельзя восстановить, кто и когда читал объекты.",
	"fix": "Блок logging или ресурс aws_s3_bucket_logging для бакета.",
}

findings contains f if {
	some r in iac.of_type("aws_s3_bucket")
	count(iac.arr(r.values, "logging")) == 0
	count(iac.of_type("aws_s3_bucket_logging")) == 0
	f := {"address": r.address, "attr": "bucket", "msg": "журнал доступа не настроен"}
}
