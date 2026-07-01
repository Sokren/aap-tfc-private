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
}

# Trigger that forces a replacement (and re-runs the job action) when any input changes
resource "terraform_data" "trigger" {
  input = "${data.aap_inventory.my_inventory.id}-${var.aap_job_id}-${jsonencode(var.inputs)}-${jsonencode({ for k, v in var.file_inputs : k => filebase64(v) })}"

  lifecycle {
    action_trigger {
      events  = [before_create, before_update]
      actions = [action.aap_job_launch.create]
    }
    action_trigger {
      events  = [before_destroy]
      actions = [action.aap_job_launch.destroy]
    }
  }

  depends_on = [
    aap_host.host,
    aws_security_group.worker,
    aws_security_group_rule.allow_ingress_controller,
    aws_security_group_rule.allow_ingress_controller_httpds,
    aws_security_group_rule.allow_ingress_controller_httpds8080,
    aws_security_group_rule.allow_egress_controller,
  ]
}
