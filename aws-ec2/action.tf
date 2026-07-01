# TF action to run the update AWS provisioning job (after the hosts get added to AAP inventory)
action "aap_job_launch" "create" {
  config {
    job_template_id     = var.aap_job_id
    inventory_id = data.aap_inventory.my_inventory.id
    wait_for_completion = true
    wait_for_completion_timeout_seconds = 600
  }
}

data "aap_job_template" "destroy_template" {
  name              = "destroy"
  organization_name = "Default" # Ajustez le nom de l'organisation si nécessaire (ex: "Default")
}

action "aap_job_launch" "destroy" {
  config {
    job_template_id     = data.aap_job_template.destroy_template.id
    inventory_id = data.aap_inventory.my_inventory.id
    wait_for_completion = true
    wait_for_completion_timeout_seconds = 600
  }
}

data "aap_job_template" "update_template" {
  name              = "update"
  organization_name = "Default" # Ajustez le nom de l'organisation si nécessaire (ex: "Default")
}

action "aap_job_launch" "update" {
  config {
    job_template_id     = data.aap_job_template.update_template.id
    inventory_id = data.aap_inventory.my_inventory.id
    wait_for_completion = true
    wait_for_completion_timeout_seconds = 600
  }
}