package rules.iam_009

import rego.v1

import data.lib.iac

meta := {
	"id": "IAM-009",
	"severity": "critical",
	"class": "Избыточные права",
	"title": "Политика IAM AWS «*» на «*»",
	"description": "Allow с Action \"*\" и Resource \"*\" равен правам администратора аккаунта.",
	"fix": "Перечислите конкретные действия и ARN ресурсов.",
}

policy_types := {"aws_iam_policy", "aws_iam_role_policy", "aws_iam_user_policy", "aws_iam_group_policy", "aws_s3_bucket_policy", "aws_kms_key"}

findings contains f if {
	some r in iac.of_types(policy_types)
	raw := iac.val(r.values, "policy", "")
	is_string(raw)
	json.is_valid(raw)
	doc := json.unmarshal(raw)
	some st in statements(doc)
	object.get(st, "Effect", "") == "Allow"
	"*" in as_list(object.get(st, "Action", []))
	"*" in as_list(object.get(st, "Resource", []))
	f := {"address": r.address, "attr": "policy", "msg": "Allow Action \"*\" на Resource \"*\""}
}

statements(doc) := doc.Statement if is_array(doc.Statement)

statements(doc) := [doc.Statement] if is_object(doc.Statement)

as_list(v) := v if is_array(v)

as_list(v) := [v] if is_string(v)
