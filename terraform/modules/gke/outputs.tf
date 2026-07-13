output "cluster_name" {
  description = "GKE cluster name."
  value       = google_container_cluster.primary.name
}

output "cluster_location" {
  description = "GKE cluster zone."
  value       = google_container_cluster.primary.location
}

output "node_service_account_email" {
  description = "Email of the node service account."
  value       = google_service_account.nodes.email
}
