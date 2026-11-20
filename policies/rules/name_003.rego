package rules.name_003

import rego.v1

import data.lib.iac

meta := {
	"id": "NAME-003",
	"severity": "medium",
	"class": "Именование",
	"title": "Имя бакета не по соглашению",
	"description": "Имена бакетов — строчные буквы, цифры и дефис, без точек и подчёркиваний, от 3 до 63 символов.",
	"fix": "Например: shop-dev-backups.",
}

types := {"aws_s3_bucket": "bucket", "google_storage_bucket": "name", "azurerm_storage_container": "name"}

pattern := "^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$"

findings contains f if {
	some r in iac.resources
	attr := types[r.type]
	name := iac.val(r.values, attr, "")
	is_string(name)
	name != ""
	not contains(name, "${")
	not regex.match(pattern, name)
	f := {"address": r.address, "attr": attr, "msg": sprintf("имя %q не соответствует %s", [name, pattern])}
}
