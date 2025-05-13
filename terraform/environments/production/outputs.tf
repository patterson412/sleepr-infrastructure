# EKS Cluster Outputs (from official AWS module)
output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group IDs attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider"
  value       = module.eks.oidc_provider_arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required for communication with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

# Networking Module Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = module.networking.nat_gateway_id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.networking.internet_gateway_id
}

# MongoDB Atlas Module Outputs
output "mongodb_cluster_id" {
  description = "MongoDB Atlas cluster ID"
  value       = module.mongodb_atlas.cluster_id
}

output "mongodb_cluster_name" {
  description = "MongoDB Atlas cluster name"
  value       = module.mongodb_atlas.cluster_name
}

output "mongodb_connection_string" {
  description = "MongoDB Atlas connection string"
  value       = module.mongodb_atlas.connection_string
  sensitive   = true
}

output "mongodb_srv_connection_string" {
  description = "MongoDB Atlas SRV connection string"
  value       = module.mongodb_atlas.srv_connection_string
  sensitive   = true
}

output "mongodb_database_user" {
  description = "MongoDB Atlas database user"
  value       = module.mongodb_atlas.database_user
}

# ECR Module Outputs
output "ecr_repository_urls" {
  description = "URLs of the ECR repositories"
  value       = module.ecr.repository_urls
}

output "ecr_repository_arns" {
  description = "ARNs of the ECR repositories"
  value       = module.ecr.repository_arns
}

# EKS Blueprints Addons Output
output "aws_load_balancer_controller" {
  description = "Map of attributes of the Helm release and IRSA created for AWS Load Balancer Controller"
  value       = module.eks_blueprints_addons.aws_load_balancer_controller
}