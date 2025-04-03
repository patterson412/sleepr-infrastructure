provider "aws" {
  region = var.aws_region
}

module "networking" {
  source = "../../modules/networking"

  environment       = "development"
  vpc_cidr          = var.vpc_cidr
  availability_zones = var.availability_zones
  private_subnets   = var.private_subnets
  public_subnets    = var.public_subnets
}

module "ecr" {
  source = "../../modules/ecr"

  repositories = [
    "auth",
    "notifications",
    "payments",
    "reservations"
  ]
}

# Elastic Beanstalk for development environment
module "elastic_beanstalk" {
  source = "../../modules/elastic-beanstalk"

  application_name = "sleepr"
  environment      = "development"
  vpc_id           = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  instance_type    = var.instance_type
  min_size         = var.min_size
  max_size         = var.max_size
  solution_stack_name = var.solution_stack_name
  
  # Environment variables for the application
  env_vars = {
    NODE_ENV        = "development"
    MONGODB_URI     = module.mongodb_atlas.connection_string
    JWT_SECRET      = var.jwt_secret
    JWT_EXPIRATION  = "3600"
    HTTP_PORT       = "3003"
    TCP_PORT        = "3002"
    PORT            = "3000"
    STRIPE_SECRET_KEY = var.stripe_secret_key
    GOOGLE_OAUTH_CLIENT_ID = var.google_oauth_client_id
    GOOGLE_OAUTH_CLIENT_SECRET = var.google_oauth_client_secret
    GOOGLE_OAUTH_REFRESH_TOKEN = var.google_oauth_refresh_token
  }
}

# We'll use MongoDB Atlas for the database
module "mongodb_atlas" {
  source = "../../modules/mongodb-atlas"

  project_name  = var.mongodb_project_name
  environment   = "development"
  cluster_type  = var.mongodb_cluster_type
  instance_size = var.mongodb_instance_size
  mongodb_version = var.mongodb_version
  region        = var.mongodb_region
  cloud_provider = "AWS"
}