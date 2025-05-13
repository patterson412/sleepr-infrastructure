terraform {
  required_version = ">= 1.11.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"         # Allows any AWS provider version 5.x (5.0.0 through 5.999.999)
                                 # This is more flexible to accommodate AWS service updates
    }
    kubernetes = {
      source  = "hashicorp/kubernetes" 
      version = "~> 2.36.0"      # Only allows patch updates (2.36.0, 2.36.1, etc.) but not 2.37.0+
                                 # Strictly controls Kubernetes provider for cluster stability
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17.0"      # Only allows patch updates (2.17.0, 2.17.1, etc.) but not 2.18.0+
                                 # Ensures Helm charts install consistently with only bug fixes
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.34.0"      # Only allows patch updates (1.34.0, 1.34.1, etc.) but not 1.35.0+
                                 # Ensures MongoDB Atlas resources remain stable with only bug fixes
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "mongodbatlas" {
  public_key  = var.mongodb_atlas_public_key
  private_key = var.mongodb_atlas_private_key
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
    command     = "aws"
  }
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

# Replaced custom EKS module with official AWS module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"
  
  cluster_name    = "sleepr-development"
  cluster_version = var.eks_version

  # Disable CloudWatch logs
  create_cloudwatch_log_group = false
  cluster_enabled_log_types   = []  # Disable all logging types
  
  # Disable KMS key and encryption
  create_kms_key              = false
  cluster_encryption_config   = {}  # Disable encryption config
  
  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.private_subnet_ids
  
  # EKS Addons with Fargate support
  cluster_addons = {
    coredns = {
      configuration_values = jsonencode({
        computeType = "Fargate"
        resources = {
          limits = {
            cpu = "0.25"
            memory = "256M"
          }
          requests = {
            cpu = "0.25"
            memory = "256M"
          }
        }
      })
    }
    kube-proxy = {}
    vpc-cni    = {}
  }
  
  # Fargate profiles
  fargate_profiles = {
    kube_system = {
      name = "kube-system"
      selectors = [
        { namespace = "kube-system" }
      ]
    }
    sleepr = {
      name = "sleepr"
      selectors = [
        { namespace = "sleepr" }
      ]
    }
  }
  
  tags = {
    Environment = "development"
  }
}

# Add the EKS Blueprints Addons module exactly per docs, 
# but with only AWS Load Balancer Controller enabled
module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = module.eks.cluster_id
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = var.eks_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  # Only enabling load balance controller
  enable_aws_load_balancer_controller = true
  
  # These parameters need default values to prevent null reference errors
  aws_for_fluentbit_cw_log_group = {}
  aws_node_termination_handler_sqs = {}
  fargate_fluentbit = {}
  fargate_fluentbit_cw_log_group = {}
  karpenter_node = {}
  karpenter_sqs = {}
  
  tags = {
    Environment = "development"
  }
}

# Create the sleepr namespace
resource "kubernetes_namespace" "sleepr" {
  depends_on = [module.eks]
  
  metadata {
    name = "sleepr"
    labels = {
      name = "sleepr"
      environment = "development"
    }
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

  mongodb_atlas_public_key = var.mongodb_atlas_public_key
  mongodb_atlas_private_key = var.mongodb_atlas_private_key
  mongodb_atlas_org_id = var.mongodb_atlas_org_id
  mongodb_user_password = var.mongodb_user_password
}