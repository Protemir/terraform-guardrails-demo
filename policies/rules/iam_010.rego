package rules.iam_010

import rego.v1

import data.lib.iac

meta := {
	"id": "IAM-010",
	"severity": "high",
	"class": "Избыточные права",
	"title": "Широкая административная роль в облаке",
	"description": "Роли owner/editor GCP, Owner Azure на подписке или AdministratorAccess AWS выдают права на весь проект.",
	"fix": "Выдайте узкие предопределённые или собственные роли.",
}

findings contains f if {
	some r in iac.of_types({"google_project_iam_member", "google_project_iam_binding", "google_folder_iam_member", "google_organization_iam_member"})
	iac.val(r.values, "role", "") in {"roles/owner", "roles/editor"}
	f := {"address": r.address, "attr": "role", "msg": sprintf("выдана роль %s", [r.values.role])}
}

findings contains f if {
	some r in iac.of_type("azurerm_role_assignment")
	iac.val(r.values, "role_definition_name", "") in {"Owner", "Contributor", "User Access Administrator"}
	scope := iac.val(r.values, "scope", "")
	is_string(scope)
	not contains(scope, "/resourceGroups/")
	f := {"address": r.address, "attr": "role_definition_name", "msg": sprintf("%s на уровне подписки", [r.values.role_definition_name])}
}

findings contains f if {
	some r in iac.of_types({"aws_iam_role_policy_attachment", "aws_iam_user_policy_attachment", "aws_iam_group_policy_attachment", "aws_iam_policy_attachment"})
	endswith(iac.val(r.values, "policy_arn", ""), ":policy/AdministratorAccess")
	f := {"address": r.address, "attr": "policy_arn", "msg": "подключена AdministratorAccess"}
}
