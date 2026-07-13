output "cluster_name" {
  description = "GKE cluster name."
  value       = module.gke.cluster_name
}

output "cluster_location" {
  description = "GKE cluster zone."
  value       = module.gke.cluster_location
}

output "get_credentials_command" {
  description = "Run this to configure kubectl against the cluster."
  value       = "gcloud container clusters get-credentials ${module.gke.cluster_name} --zone ${var.zone} --project ${var.project_id}"
}

output "artifact_registry_url" {
  description = "Base URL to tag/push the app image to."
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${module.artifact_registry.repository_id}"
}

output "model_bucket" {
  description = "GCS bucket for model weights (gs:// URI)."
  value       = "gs://${module.storage.bucket_name}"
}

output "app_service_account_email" {
  description = "Google SA to annotate the Kubernetes ServiceAccount with."
  value       = module.storage.app_service_account_email
}

output "ksa_annotation_command" {
  description = "Wire the Kubernetes ServiceAccount to the Google SA (Workload Identity)."
  value       = "kubectl annotate serviceaccount ${var.k8s_service_account} -n ${var.k8s_namespace} iam.gke.io/gcp-service-account=${module.storage.app_service_account_email}"
}
