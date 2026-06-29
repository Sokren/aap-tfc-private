terraform {
  required_version = "~> v1.15.0"
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.99.0"
    }
    aap = {
      source  = "ansible/aap"
      version = "1.5.0"
    }
  }
}

data "terraform_remote_state" "aws_infra" {
  backend = "remote"
  config = {
    organization = var.tfc_org
    workspaces = {
      name = "AAP-TFC-aws-infra"
    }
  }
}


provider "aws" {
  region  = var.region
}

#@provider "aap" {
#  host                 = var.aap_host_url
#  username             = var.aap_username
#  password             = var.aap_password
#}

resource "random_pet" "test" {
  length = 1
}
