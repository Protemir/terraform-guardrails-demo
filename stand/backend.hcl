# Состояние Terraform/OpenTofu в MinIO стенда. Ключи — AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY.
bucket                      = "tfstate"
key                         = "stand/terraform.tfstate"
region                      = "us-east-1"
endpoints                   = { s3 = "http://localhost:9000" }
use_path_style              = true
use_lockfile                = true
skip_credentials_validation = true
skip_requesting_account_id  = true
skip_metadata_api_check     = true
skip_region_validation      = true
skip_s3_checksum            = true
