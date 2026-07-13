output "bucket_name" {
  description = "Name of the model bucket."
  value       = google_storage_bucket.models.name
}

output "app_service_account_email" {
  description = "Email of the workload-identity SA used by vLLM/app pods."
  value       = google_service_account.app.email
}
