output "app_url" {
  description = "Адрес демо-приложения на стенде."
  value       = "https://shop.127.0.0.1.nip.io:8443"
}

output "database" {
  description = "Подключение к базе приложения."
  value = {
    host   = module.shop_db.rw_host
    secret = module.shop_db.app_secret_name
  }
}

output "chart_versions" {
  description = "Версии платформенных чартов."
  value       = module.ingress.versions
}
