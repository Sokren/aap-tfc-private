####################################################################
# Job templates AAP + actions de lancement
# AAP job templates and their launch actions
####################################################################

# --- Provisioning initial httpd / Initial httpd provisioning -------
data "aap_job_template" "create_template" {
  name              = "tfc_httpd-config"
  organization_name = "Default" # Ajustez si nécessaire / Adjust if needed
}

action "aap_job_launch" "create" {
  config {
    job_template_id                     = data.aap_job_template.create_template.id
    inventory_id                        = data.aap_inventory.my_inventory.id
    wait_for_completion                 = true
    wait_for_completion_timeout_seconds = 600
  }
}

# --- Destruction / Teardown ----------------------------------------
data "aap_job_template" "destroy_template" {
  name              = "tfc_destroy"
  organization_name = "Default" # Ajustez si nécessaire / Adjust if needed
}

action "aap_job_launch" "destroy" {
  config {
    job_template_id                     = data.aap_job_template.destroy_template.id
    inventory_id                        = data.aap_inventory.my_inventory.id
    wait_for_completion                 = true
    wait_for_completion_timeout_seconds = 600
  }
}

# --- Mise à jour du site / Website update --------------------------
data "aap_job_template" "update_template" {
  name              = "tfc_update"
  organization_name = "Default" # Ajustez si nécessaire / Adjust if needed
}

action "aap_job_launch" "update" {
  config {
    job_template_id                     = data.aap_job_template.update_template.id
    inventory_id                        = data.aap_inventory.my_inventory.id
    wait_for_completion                 = true
    wait_for_completion_timeout_seconds = 600
  }
}
