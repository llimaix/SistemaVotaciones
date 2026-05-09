terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # ── Remote State en S3 ──────────────────────────────────
  # IMPORTANTE: Este bucket y la tabla DynamoDB deben existir
  # ANTES del primer `terraform init`. Créalos manualmente una
  # sola vez o con el script infra/scripts/bootstrap.sh
  backend "s3" {
    bucket         = "sistema-votaciones-tf-state" # ← cambia por tu bucket
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "sistema-votaciones-tf-locks" # ← tabla DynamoDB para locking
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
