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
    bucket         = "terraform-20231013120105412600000001" # Update with bucket name after it is created
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform_state"
  }
  # Remote State File Configs End
}

provider "aws" {
  # Configuration options
}
