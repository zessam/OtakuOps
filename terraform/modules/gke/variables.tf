variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "name" {
  description = "Cluster name (also prefixes the node service account)."
  type        = string
}

variable "zone" {
  description = "Zone for the zonal cluster and node pools."
  type        = string
}

variable "network_id" {
  description = "VPC network ID."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID."
  type        = string
}

variable "pods_range_name" {
  description = "Secondary range name for pods."
  type        = string
}

variable "services_range_name" {
  description = "Secondary range name for services."
  type        = string
}

variable "app_machine_type" {
  description = "Machine type for the always-on app node pool."
  type        = string
}

variable "serve_machine_type" {
  description = "Machine type for the vLLM CPU serving pool."
  type        = string
}

variable "master_authorized_cidrs" {
  description = "CIDRs allowed to reach the control-plane endpoint. Empty = allow all."
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Common resource labels."
  type        = map(string)
  default     = {}
}

variable "disk_size_gb" {
  description = "Boot disk size for nodes (GB). Kept small to save free-tier cost."
  type        = number
  default     = 50
}

variable "disk_type" {
  description = "Boot disk type for nodes. pd-standard is the cheapest."
  type        = string
  default     = "pd-standard"
}
