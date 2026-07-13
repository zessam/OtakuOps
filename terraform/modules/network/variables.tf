variable "name_prefix" {
  description = "Prefix for network resource names (usually the cluster name)."
  type        = string
}

variable "region" {
  description = "Region for the subnet, router and NAT."
  type        = string
}

variable "subnet_cidr" {
  description = "Primary CIDR range for the subnet."
  type        = string
  default     = "10.10.0.0/16"
}

variable "pods_cidr" {
  description = "Secondary CIDR range for GKE pods."
  type        = string
  default     = "10.20.0.0/16"
}

variable "services_cidr" {
  description = "Secondary CIDR range for GKE services."
  type        = string
  default     = "10.30.0.0/20"
}
