variable "project_name" {
  description = "MongoDB Atlas project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_type" {
  description = "MongoDB Atlas cluster type (REPLICASET, SHARDED)"
  type        = string
  default     = "REPLICASET"
}

variable "instance_size" {
  description = "MongoDB Atlas instance size (M0, M2, M5, M10, etc.)"
  type        = string
}

variable "mongodb_version" {
  description = "MongoDB version"
  type        = string
  default     = "6.0"
}

variable "region" {
  description = "MongoDB Atlas region"
  type        = string
}

variable "cloud_provider" {
  description = "MongoDB Atlas cloud provider (AWS, GCP, AZURE)"
  type        = string
  default     = "AWS"
}

variable "mongodb_atlas_public_key" {
  description = "MongoDB Atlas public key"
  type        = string
  sensitive   = true
}

variable "mongodb_atlas_private_key" {
  description = "MongoDB Atlas private key"
  type        = string
  sensitive   = true
}

variable "mongodb_atlas_org_id" {
  description = "MongoDB Atlas organization ID"
  type        = string
  sensitive   = true
}

variable "mongodb_user_password" {
  description = "Password for MongoDB database user"
  type        = string
  sensitive   = true
}

variable "app_cidr_block" {
  description = "CIDR block to allow access to MongoDB"
  type        = string
  default     = "0.0.0.0/0"  # Open to all IPs - restrict this in production
}