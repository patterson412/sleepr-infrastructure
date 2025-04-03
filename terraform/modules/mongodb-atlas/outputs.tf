output "cluster_id" {
  description = "MongoDB Atlas cluster ID"
  value       = mongodbatlas_cluster.cluster.id
}

output "cluster_name" {
  description = "MongoDB Atlas cluster name"
  value       = mongodbatlas_cluster.cluster.name
}

output "connection_string" {
  description = "MongoDB Atlas connection string"
  value       = mongodbatlas_cluster.cluster.connection_strings[0].standard
  sensitive   = true
}

output "srv_connection_string" {
  description = "MongoDB Atlas SRV connection string"
  value       = mongodbatlas_cluster.cluster.connection_strings[0].standard_srv
  sensitive   = true
}

output "database_user" {
  description = "MongoDB Atlas database user"
  value       = mongodbatlas_database_user.user.username
}