terraform {
  required_providers {
    aap = {
      source  = "ansible/aap"
      version = "1.3.0-prerelease2"
    }
  }
}

data "terraform_remote_state" "aws-ec2" {
  backend = "remote"

  config = {
    organization = var.tfc_org
    workspaces = {
      name = "AAP-TFC-aws-ec2"
    }
  }
}
