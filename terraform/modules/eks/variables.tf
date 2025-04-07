variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "eks_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
}

variable "fargate_profiles" {
  description = "Map of Fargate profiles to create"
  type = map(object({
    name = string
    selectors = list(object({
      namespace = string
      labels    = map(string)
    }))
  }))
  default = {}
}