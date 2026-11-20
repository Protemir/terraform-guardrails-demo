# Пример для правила ENC-006: ресурсы bad_* нарушают правило, good_* — нет.

resource "google_sql_database_instance" "bad_no_ssl" {
  name             = "shop"
  database_version = "POSTGRES_16"
  settings {
    tier = "db-f1-micro"
    ip_configuration {
      require_ssl = false
    }
  }
}

resource "google_sql_database_instance" "good_ssl" {
  name             = "shop"
  database_version = "POSTGRES_16"
  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ssl_mode = "ENCRYPTED_ONLY"
    }
  }
}
