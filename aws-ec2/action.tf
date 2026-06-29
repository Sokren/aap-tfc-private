# TF action to run the update AWS provisioning job (after the hosts get added to AAP inventory)
action "aap_job_launch" "create" {
  config {
    job_template_id     = var.aap_job_id
    inventory_id = data.aap_inventory.my_inventory.id
    wait_for_completion = true
    wait_for_completion_timeout_seconds = 600
  }
}
