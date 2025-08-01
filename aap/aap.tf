provider "aap" {
  host                 = var.aap_host_url
  username             = var.aap_username
  password             = var.aap_password
}

 resource "aap_inventory" "my_inventory" {
   name = "TFE_Apache-servers"
 }

resource "aap_host" "create_host" {
  inventory_id = aap_inventory.my_inventory.id
  name         = data.terraform_remote_state.aws-ec2.outputs.ec2_first_addr
}

resource "aap_job" "run_job_template" {
  job_template_id = var.job_template_id
  inventory_id    = aap_inventory.my_inventory.id
  wait_for_completion                 = true
  wait_for_completion_timeout_seconds = 120
  extra_vars = <<EOT
{
  "inventory": "${aap_inventory.my_inventory.name}"
}
EOT
  depends_on = [
    aap_host.create_host
  ]
}
