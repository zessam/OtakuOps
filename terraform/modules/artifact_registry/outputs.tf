output "repository_id" {
  description = "Artifact Registry repository ID."
  value       = google_artifact_registry_repository.repo.repository_id
}
