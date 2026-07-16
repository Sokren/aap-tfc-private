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

# --- Vault (API HTTP) / Vault (HTTP API) ---------------------------
# Adresse de base Vault / Vault base URL (ex: https://vault.example:8200)
variable "vault_addr" {
  type = string
}

# Token d'auth Vault (header X-Vault-Token) / Vault auth token
variable "vault_token" {
  type      = string
  sensitive = true
}

# Namespace Vault (Enterprise/HCP) / Vault namespace
variable "vault_namespace" {
  type    = string
  default = "admin"
}

# Mount du moteur KV v2 / KV v2 engine mount
variable "vault_kv_mount" {
  type    = string
  default = "tfe-vault-aap-onchange"
}

# Ignorer la vérif TLS (Vault auto-signé) / Skip TLS verify (self-signed Vault)
variable "vault_skip_verify" {
  type    = bool
  default = false
}
