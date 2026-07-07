####################################################################
# Intégration AAP : inventaire, groupe, hosts et trigger de relance
# AAP integration: inventory, group, hosts and re-run trigger
####################################################################

provider "aap" {
  host                 = var.aap_host_url
  username             = var.aap_username
  password             = var.aap_password
  insecure_skip_verify = true
}

# Inventaire cible dans AAP / Target inventory in AAP
data "aap_inventory" "my_inventory" {
  name              = "TFE_Web-servers"
  organization_name = "Default"
}

# Groupe regroupant les serveurs web / Group holding the web servers
resource "aap_group" "tfademo" {
  inventory_id = data.aap_inventory.my_inventory.id
  name         = "tfademo"
  variables    = jsonencode({ "ansible_network_os" : "ubuntu" })
}

# Ajoute chaque instance EC2 à l'inventaire / Add each EC2 instance to the inventory
resource "aap_host" "host" {
  for_each     = { for idx, instance in aws_instance.web_server : idx => instance }
  inventory_id = data.aap_inventory.my_inventory.id
  groups       = toset([resource.aap_group.tfademo.id])
  name         = each.value.public_ip
  description  = "Host provisioned by Terraform"
  variables = jsonencode({
    ansible_user = "ec2-user"
    public_ip    = each.value.public_ip
    target_hosts = each.value.public_ip
  })
}

# Hash agrégé de tous les fichiers du site.
# Aggregated hash of every website file.
# NB: working directory TFE = aws-ec2, donc le site est à ../website/Version-RH-HC
locals {
  website_dir = "${path.module}/../website/Version-RH-HC"
  website_hash = sha256(join("", [
    for f in sort(fileset(local.website_dir, "**")) :
    filesha256("${local.website_dir}/${f}")
  ]))
}

# Force un remplacement (et relance l'action AAP) dès qu'un input change.
# Forces a replacement (and re-runs the AAP action) whenever an input changes.
resource "terraform_data" "trigger" {
  input = join("-", [
    data.aap_inventory.my_inventory.id,                    # inventaire / inventory
    var.aap_job_id,                                        # job template id
    jsonencode([for k, h in aap_host.host : h.variables]), # variables des hosts / host vars
    filesha256("${path.module}/playbook/update.yml"),      # playbook
    local.website_hash,                                    # contenu du site / site content
  ])

  lifecycle {
    action_trigger {
      events  = [before_create]
      actions = [action.aap_job_launch.create]
    }
    action_trigger {
      events  = [before_update]
      actions = [action.aap_job_launch.update]
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
