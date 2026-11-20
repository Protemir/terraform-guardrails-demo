package rules.tag_001

import rego.v1

import data.lib.iac

meta := {
	"id": "TAG-001",
	"severity": "high",
	"class": "Обязательные метки",
	"title": "Облачный ресурс без меток владельца, окружения и центра затрат",
	"description": "Ресурс без owner / environment / cost-center нельзя отнести к команде и бюджету.",
	"fix": "Задайте tags (AWS, Azure) или labels (GCP); в AWS удобно через default_tags провайдера.",
}

default_required := ["owner", "environment", "cost-center"]

required := object.get(iac.config, "required_tags", default_required)

# Типы, которые точно поддерживают метки: нужны для HCL, где неуказанный атрибут отсутствует.
taggable_hcl := {
	"aws_instance", "aws_s3_bucket", "aws_db_instance", "aws_rds_cluster", "aws_vpc", "aws_subnet",
	"aws_security_group", "aws_ebs_volume", "aws_lb", "aws_alb", "aws_eks_cluster", "aws_lambda_function",
	"aws_dynamodb_table", "aws_kms_key", "aws_iam_role", "aws_sqs_queue", "aws_sns_topic",
	"aws_elasticsearch_domain", "aws_opensearch_domain", "aws_ecr_repository", "aws_efs_file_system",
	"aws_neptune_cluster", "aws_redshift_cluster", "aws_cloudtrail",
	"azurerm_resource_group", "azurerm_storage_account", "azurerm_linux_virtual_machine",
	"azurerm_windows_virtual_machine", "azurerm_virtual_machine", "azurerm_kubernetes_cluster",
	"azurerm_key_vault", "azurerm_virtual_network", "azurerm_network_security_group",
	"azurerm_mssql_server", "azurerm_postgresql_server", "azurerm_mysql_server",
	"google_compute_instance", "google_storage_bucket", "google_container_cluster", "google_compute_disk",
}

cloud(t) if startswith(t, "aws_")

cloud(t) if startswith(t, "azurerm_")

cloud(t) if startswith(t, "google_")

attr_of(t) := "labels" if startswith(t, "google_")

attr_of(t) := "tags" if not startswith(t, "google_")

# Метки известны и их можно проверить.
tag_set(r) := t if {
	iac.is_plan
	t := iac.obj(r.values, "tags_all")
	count(t) > 0
} else := t if {
	t := object.get(r.values, attr_of(r.type), null)
	is_object(t)
} else := {} if {
	object.get(r.values, attr_of(r.type), null) == null
}

taggable(r) if {
	iac.is_plan
	attr_of(r.type) in object.keys(r.values)
}

taggable(r) if {
	not iac.is_plan
	r.type in taggable_hcl
}

norm(k) := replace(lower(k), "_", "-")

findings contains f if {
	some r in iac.resources
	cloud(r.type)
	taggable(r)
	tags := tag_known(r)
	keys := {norm(k) | some k, _ in tags}
	missing := [k | some k in required; not k in keys; not alias(k, keys)]
	count(missing) > 0
	f := {"address": r.address, "attr": attr_of(r.type), "msg": sprintf("нет обязательных меток: %s", [concat(", ", missing)])}
}

# В HCL метки могут не указываться вовсе — тогда это пустой набор.
tag_known(r) := tag_set(r) if not iac.is_plan

tag_known(r) := tag_set(r) if {
	iac.is_plan
	not r.unknown.tags_all == true
	not r.unknown.tags == true
}

alias("cost-center", keys) if "costcenter" in keys

alias("cost-center", keys) if "cost" in keys

alias("environment", keys) if "env" in keys
