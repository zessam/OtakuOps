# Docker repository for the app image.
resource "google_artifact_registry_repository" "repo" {
  #checkov:skip=CKV_GCP_84:Google-managed encryption is acceptable; CMEK/CSEK omitted to keep free-tier cost/complexity down.
  location      = var.region
  repository_id = var.repository_id
  format        = "DOCKER"
  description   = "Anime recommender app images"
}
