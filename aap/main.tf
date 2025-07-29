terraform {
  required_providers {
    aap = {
      #source  = "ansible/aap"
      #version = "1.3.0-prerelease2"
      source  = "app.terraform.io/salandre-co/aaptest/provider"
      version = "1.0.0"
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
