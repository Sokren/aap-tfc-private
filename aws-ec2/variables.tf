####################################################################
# Locals & variables d'entrée
# Locals and input variables
####################################################################

locals {
  # Tag commun appliqué aux ressources / Common tag applied to resources
  tags = {
    Name = "${var.tag}-${random_pet.test.id}"
  }
}

# --- Général / General ---------------------------------------------
variable "tag" {
  type = string
}

variable "pub_ssh_key" {
  type = string
}

variable "priv_ssh_key" {
  default = ""
}

# Nombre d'instances web à créer / Number of web instances to create
variable "num_web_servers" {
  default = 2
}

variable "tfc_org" {
  type = string
}

variable "region" {
  type = string
}

# --- AAP (Ansible Automation Platform) -----------------------------
variable "aap_host_url" {
  type = string
}

variable "aap_username" {
  type = string
}

variable "aap_password" {
  type = string
}

# Job template id utilisé par le trigger / Job template id used by the trigger
variable "aap_job_id" {
  type    = string
  default = "9"
}
