output "cluster_name" {
  description = "Имя кластера CloudNativePG."
  value       = var.name
}

output "rw_host" {
  description = "Адрес основного экземпляра (чтение и запись)."
  value       = "${var.name}-rw.${var.namespace}.svc"
}

output "ro_host" {
  description = "Адрес реплик (только чтение)."
  value       = "${var.name}-ro.${var.namespace}.svc"
}

output "app_secret_name" {
  description = "Секрет с логином, паролем и URI для приложения (создаёт оператор)."
  value       = "${var.name}-app"
}

output "object_store" {
  description = "Имя ObjectStore с резервными копиями — для восстановления другим кластером."
  value       = var.backup.enabled ? local.store_name : null
}
