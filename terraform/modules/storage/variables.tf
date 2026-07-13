variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "Region (location) for the bucket."
  type        = string
}

variable "bucket_name" {
  description = "Globally-unique name for the model bucket."
  type        = string
}

variable "name_prefix" {
  description = "Prefix for the app service account (usually the cluster name)."
  type        = string
}

variable "k8s_namespace" {
  description = "Kubernetes namespace the vLLM/app workloads run in."
  type        = string
}

variable "k8s_service_account" {
  description = "Kubernetes ServiceAccount name the vLLM/app pods use."
  type        = string
}
