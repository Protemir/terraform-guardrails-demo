package rules.enc_003

import rego.v1

import data.lib.iac

meta := {
	"id": "ENC-003",
	"severity": "high",
	"class": "Шифрование",
	"title": "Хранилище данных без шифрования",
	"description": "Диски, базы и файловые системы создаются без шифрования при хранении.",
	"fix": "encrypted / storage_encrypted = true, при необходимости — свой ключ KMS.",
}

checks := {
	"aws_ebs_volume": "encrypted",
	"aws_efs_file_system": "encrypted",
	"aws_db_instance": "storage_encrypted",
	"aws_rds_cluster": "storage_encrypted",
	"aws_docdb_cluster": "storage_encrypted",
	"aws_neptune_cluster": "storage_encrypted",
	"aws_redshift_cluster": "encrypted",
}

findings contains f if {
	some r in iac.resources
	attr := checks[r.type]
	not iac.val(r.values, attr, false) == true
	not unknown(r, attr)
	f := {"address": r.address, "attr": attr, "msg": sprintf("%s не включено", [attr])}
}

findings contains f if {
	some r in iac.of_type("aws_instance")
	some d in iac.arr(r.values, "ebs_block_device")
	not iac.val(d, "encrypted", false) == true
	f := {"address": r.address, "attr": "ebs_block_device", "msg": "диск ebs_block_device без шифрования"}
}

findings contains f if {
	some r in iac.of_type("aws_launch_configuration")
	some d in iac.arr(r.values, "root_block_device")
	not iac.val(d, "encrypted", false) == true
	f := {"address": r.address, "attr": "root_block_device", "msg": "корневой диск без шифрования"}
}

findings contains f if {
	some r in iac.of_type("aws_sqs_queue")
	not iac.val(r.values, "sqs_managed_sse_enabled", false) == true
	iac.val(r.values, "kms_master_key_id", "") == ""
	f := {"address": r.address, "attr": "kms_master_key_id", "msg": "очередь без шифрования"}
}

unknown(r, attr) if r.unknown[attr] == true
