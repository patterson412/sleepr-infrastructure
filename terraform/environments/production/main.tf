provider "aws" {
  region = var.aws_region
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
      command     = "aws"
    }
  }
}

module "aws_load_balancer_controller" {
  source = "../../modules/aws-load-balancer-controller"

  cluster_name             = module.eks.cluster_id
  cluster_oidc_provider_arn = module.eks.oidc_provider_arn
  region                   = var.aws_region
  vpc_id                   = module.networking.vpc_id
}

module "networking" {
  source = "../../modules/networking"

  environment       = "production"
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

module "eks" {
  source = "../../modules/eks"

  cluster_name      = "sleepr-production"
  environment       = "production"
  vpc_id            = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  eks_version       = var.eks_version
  
  # Fargate profiles for each namespace
  fargate_profiles = {
    sleepr = {
      name = "sleepr"
      selectors = [
        {
          namespace = "sleepr"
          labels = {}
        }
      ]
    }
  }
}

# We'll use MongoDB Atlas for the database
module "mongodb_atlas" {
  source = "../../modules/mongodb-atlas"

  project_name  = var.mongodb_project_name
  environment   = "production"
  cluster_type  = var.mongodb_cluster_type
  instance_size = var.mongodb_instance_size
  mongodb_version = var.mongodb_version
  region        = var.mongodb_region
  cloud_provider = "AWS"

  mongodb_atlas_public_key = var.mongodb_atlas_public_key
  mongodb_atlas_private_key = var.mongodb_atlas_private_key
  mongodb_atlas_org_id = var.mongodb_atlas_org_id
  mongodb_user_password = var.mongodb_user_password
}