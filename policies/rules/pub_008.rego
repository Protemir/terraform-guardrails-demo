package rules.pub_008

import rego.v1

import data.lib.iac

meta := {
	"id": "PUB-008",
	"severity": "high",
	"class": "Публичный доступ",
	"title": "Анонимный доступ к хранилищу Azure",
	"description": "Разрешён анонимный доступ к контейнерам Blob.",
	"fix": "allow_nested_items_to_be_public = false, container_access_type = private.",
}

findings contains f if {
	some r in iac.of_type("azurerm_storage_account")
	iac.val(r.values, "allow_nested_items_to_be_public", iac.val(r.values, "allow_blob_public_access", false)) == true
	f := {"address": r.address, "attr": "allow_nested_items_to_be_public", "msg": "разрешён анонимный доступ к Blob"}
}

findings contains f if {
	some r in iac.of_type("azurerm_storage_container")
	iac.val(r.values, "container_access_type", "private") in {"blob", "container"}
	f := {"address": r.address, "attr": "container_access_type", "msg": sprintf("container_access_type = %s", [r.values.container_access_type])}
}
