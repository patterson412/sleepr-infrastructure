terraform {
  required_version = ">= 1.11.3"

  backend "s3" {
    bucket         = "sleepr-terraform-state"
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "sleepr-terraform-locks"
    encrypt        = true
  }
}