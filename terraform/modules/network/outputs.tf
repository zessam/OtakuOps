output "network_id" {
  description = "Self-link/ID of the VPC."
  value       = google_compute_network.vpc.id
}

output "subnet_id" {
  description = "Self-link/ID of the subnet."
  value       = google_compute_subnetwork.subnet.id
}

output "pods_range_name" {
  description = "Secondary range name for pods."
  value       = google_compute_subnetwork.subnet.secondary_ip_range[0].range_name
}

output "services_range_name" {
  description = "Secondary range name for services."
  value       = google_compute_subnetwork.subnet.secondary_ip_range[1].range_name
}
