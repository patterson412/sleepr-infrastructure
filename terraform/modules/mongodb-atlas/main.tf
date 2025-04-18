terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.12.0"
    }
  }
}

provider "mongodbatlas" {
  public_key  = var.mongodb_atlas_public_key
  private_key = var.mongodb_atlas_private_key
}

resource "mongodbatlas_project" "project" {
  name   = "${var.project_name}-${var.environment}"
  org_id = var.mongodb_atlas_org_id
}

resource "mongodbatlas_cluster" "cluster" {
  project_id = mongodbatlas_project.project.id
  name       = "${var.project_name}-${var.environment}"

  # Cluster configuration
  provider_name         = "TENANT"
  backing_provider_name = var.cloud_provider
  provider_region_name  = var.region
  provider_instance_size_name = var.instance_size

  # MongoDB version
  mongo_db_major_version = var.mongodb_version

  # Auto-scaling configuration
  auto_scaling_disk_gb_enabled = true

  # Backup configuration - Enable for production environments
  dynamic "backup_enabled" {
    for_each = var.environment == "production" ? [1] : []
    content {
      enabled = true
    }
  }
}

# Create a MongoDB Atlas database user
resource "mongodbatlas_database_user" "user" {
  username           = "${var.project_name}_${var.environment}_user"
  password           = var.mongodb_user_password
  project_id         = mongodbatlas_project.project.id
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = "${var.project_name}_${var.environment}"
  }

  scopes {
    name = mongodbatlas_cluster.cluster.name
    type = "CLUSTER"
  }
}

# Create IP access list entry for the application to access the MongoDB cluster
resource "mongodbatlas_project_ip_access_list" "app" {
  project_id = mongodbatlas_project.project.id
  cidr_block = var.app_cidr_block
  comment    = "CIDR block for ${var.environment} environment"
}