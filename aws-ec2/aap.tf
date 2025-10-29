provider "aap" {
  host                 = var.aap_host_url
  username             = var.aap_username
  password             = var.aap_password
} 

resource "aap_inventory" "my_inventory" {
   name = "TFE_Web-servers"
 }

resource "aap_group" "tfademo" {
  inventory_id = aap_inventory.my_inventory.id
  name         = "tfademo"
  variables    = jsonencode({ "ansible_network_os" : "ubuntu" })
}

# Add the new EC2 instance to the inventory
resource "aap_host" "host" {
  for_each     = { for idx, instance in aws_instance.web_server : idx => instance }
  inventory_id = aap_inventory.my_inventory.id
  groups = toset([resource.aap_group.tfademo.id])
  name         = each.value.public_ip
  description  = "Host provisioned by Terraform"
  variables    = jsonencode({
    ansible_user = "ubuntu"
    public_ip    = each.value.public_ip
    target_hosts = each.value.public_ip
  })
  lifecycle {
    action_trigger {
      events  = [after_create]
      actions = [action.aap_eda_eventstream_post.update]
    }
  }
}

# TF action to run the update AWS provisioning job (after the hosts get added to AAP inventory)
action "aap_eda_eventstream_post" "update" {
  config {
    limit = "98.93.9.213"
    template_type = "job"
    job_template_name = "TFA Demo Apache Update"
    organization_name = "Default"
    event_stream_config = {
      url = var.aap_eventstream_url
      username = var.aap_eventstream_username
      password = var.aap_eventstream_password
    }
  }
}