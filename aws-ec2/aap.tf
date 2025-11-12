provider "aap" {
  host                 = var.aap_host_url
#  token                = "pXcfxGy2X8wrrStrHvyvhKCRKGWigv"
  username             = var.aap_username
  password             = var.aap_password
  insecure_skip_verify = true
} 

data "aap_inventory" "my_inventory" {
   name = "TFE_Web-servers"
   organization_name = "Default"
 }

resource "aap_group" "tfademo" {
  inventory_id = data.aap_inventory.my_inventory.id
  name         = "tfademo"
  variables    = jsonencode({ "ansible_network_os" : "ubuntu" })
}

# Add the new EC2 instance to the inventory
resource "aap_host" "host" {
  for_each     = { for idx, instance in aws_instance.web_server : idx => instance }
  inventory_id = data.aap_inventory.my_inventory.id
  groups = toset([resource.aap_group.tfademo.id])
  name         = each.value.public_ip
  description  = "Host provisioned by Terraform"
  variables    = jsonencode({
    ansible_user = "ec2-user"
    public_ip    = each.value.public_ip
    target_hosts = each.value.public_ip
  })
  lifecycle {
    action_trigger {
      events  = [after_create]
      actions = [action.aap_job_launch.create]
    }
  }
}

# TF action to run the update AWS provisioning job (after the hosts get added to AAP inventory)
action "aap_job_launch" "create" {
  config {
    job_template_id     = var.aap_job_id
    wait_for_completion = true
  }
}