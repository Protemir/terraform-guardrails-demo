package rules.pub_004

import rego.v1

import data.lib.iac

meta := {
	"id": "PUB-004",
	"severity": "critical",
	"class": "Публичный доступ",
	"title": "Публичный бакет S3",
	"description": "ACL public-read / public-read-write / authenticated-read или выключенная блокировка публичного доступа делают объекты бакета доступными всем.",
	"fix": "ACL private и aws_s3_bucket_public_access_block со всеми четырьмя флагами true.",
}

public_acls := {"public-read", "public-read-write", "authenticated-read", "website"}

findings contains f if {
	some r in iac.of_types({"aws_s3_bucket", "aws_s3_bucket_acl"})
	iac.val(r.values, "acl", "") in public_acls
	f := {"address": r.address, "attr": "acl", "msg": sprintf("acl = %s", [r.values.acl])}
}

findings contains f if {
	some r in iac.of_type("aws_s3_bucket_public_access_block")
	some flag in ["block_public_acls", "block_public_policy", "ignore_public_acls", "restrict_public_buckets"]
	iac.val(r.values, flag, false) == false
	f := {"address": r.address, "attr": flag, "msg": sprintf("%s не включён", [flag])}
}
