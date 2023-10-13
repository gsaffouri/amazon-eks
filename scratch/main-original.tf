terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.20.1"
    }
  }
  required_version = "~> 1.5.0"

  # Remote State File Configs Start
  # Uncomment and re-run after resources are created
  backend "s3" {
    bucket         = "terraform-20231013205601975300000001" # Update with bucket name after it is created
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform_state"
  }
  # Remote State File Configs End
}

provider "aws" {
  # Configuration options
}



module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"
  
  cluster_name    = "my-cluster"
  cluster_version = "1.27"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

}