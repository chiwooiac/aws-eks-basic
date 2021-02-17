terraform {

  required_version = ">= 0.12.21"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.22"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }

}

provider "aws" {
  region = var.aws_region
  shared_credentials_file = var.aws_credentials_file
  profile = var.aws_profile
}


/*
provider "kubernetes" {
}
provider "random" {
}

provider "local" {
}

provider "null" {
}

provider "template" {
}

*/