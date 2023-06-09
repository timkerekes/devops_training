terraform {
  cloud {
    organization = "devopswithtim"
    workspaces {
      name = "aws-organizations-setup"
    }
  }


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.64.0"
    }
  }

  required_version = ">= 1.4.0"
}
