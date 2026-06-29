locals {
  tags = {
    Name = "${var.tag}-${random_pet.test.id}"
  }

  pub_cidrs  = cidrsubnets("10.0.0.0/24", 4, 4, 4, 4)
  priv_cidrs = cidrsubnets("10.0.100.0/24", 4, 4, 4, 4)
}

variable "tag" {
  type = string
}

variable "pub_ssh_key" {
  type = string
}

variable "priv_ssh_key" {
  default = ""
}

variable "num_web_servers" {
  default = 2
}

variable "tfc_org" {
  type = string
}

variable "region" {
  type = string
}

#AAP variables
variable "aap_host_url" {
  type = string
}

variable "aap_username" {
  type = string
}

variable "aap_password" {
  type = string
}

#AAP EDA variables
variable "aap_eventstream_url" {
  type = string
}

variable "aap_eventstream_username" {
  type = string
}

variable "aap_eventstream_password" {
  type = string
}

variable "aap_job_id" {
  type = string
  default = "9"
}

# Inputs used to build the terraform_data trigger
variable "inventory_id" {
  type    = string
  default = ""
}

variable "template_id" {
  type    = string
  default = ""
}

variable "inputs" {
  type    = map(string)
  default = {}
}

variable "file_inputs" {
  type    = map(string)
  default = {}
}