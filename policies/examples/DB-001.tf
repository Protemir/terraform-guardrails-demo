# Пример для правила DB-001: ресурсы bad_* нарушают правило, good_* — нет.

resource "aws_db_instance" "bad_no_backups" {
  engine                  = "postgres"
  backup_retention_period = 0
}

resource "helm_release" "bad_cnpg_no_backup" {
  name  = "shop-db"
  chart = "../../modules/postgres-cnpg/charts/cnpg-cluster"
  values = [<<EOF
instances: 2
backup:
  enabled: false
EOF
  ]
}

resource "aws_db_instance" "good_backups" {
  engine                  = "postgres"
  backup_retention_period = 14
}

resource "helm_release" "good_cnpg_backup" {
  name  = "shop-db"
  chart = "../../modules/postgres-cnpg/charts/cnpg-cluster"
  values = [<<EOF
instances: 2
backup:
  enabled: true
  retention: 14d
EOF
  ]
}
