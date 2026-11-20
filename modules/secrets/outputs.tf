output "controller_name" {
  description = "Имя контроллера (флаг --controller-name для kubeseal)."
  value       = "sealed-secrets-controller"
}

output "controller_namespace" {
  description = "Пространство имён контроллера (флаг --controller-namespace для kubeseal)."
  value       = var.namespace
}

output "seal_command" {
  description = "Как зашифровать значение для переменной sealed_secrets."
  value       = "echo -n 'значение' | kubeseal --raw --controller-name sealed-secrets-controller --controller-namespace ${var.namespace} --namespace <ns> --name <имя секрета>"
}

output "secret_names" {
  description = "Созданные секреты."
  value       = keys(var.sealed_secrets)
}
