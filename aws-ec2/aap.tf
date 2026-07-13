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
# La config Vault est portée par les group vars (héritées par les hôtes) : elle
# n'entre donc PAS dans terraform_data.trigger.input (qui ne hache que les host
# vars) → le token ne fuite ni dans le trigger ni dans l'output.
# Vault config lives in group vars (inherited by hosts): it is NOT part of
# terraform_data.trigger.input (which only hashes host vars) → the token leaks
# neither into the trigger nor into the outputs.
resource "aap_group" "tfademo" {
  inventory_id = data.aap_inventory.my_inventory.id
  name         = "tfademo"
  variables = jsonencode({
    vault_addr        = var.vault_addr
    vault_token       = var.vault_token
    vault_namespace   = var.vault_namespace
    vault_kv_mount    = var.vault_kv_mount
    vault_skip_verify = var.vault_skip_verify
  })
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

  # Une fois l'hôte ajouté à l'inventaire, on lance le job de config httpd
  # ciblé sur CET hôte. Puis, avant de le retirer, le job de destruction
  # ciblé lui aussi sur CET hôte (via `caller.name` dans les actions).
  # After the host is added to the inventory, run the httpd config job scoped
  # to THIS host. Before it is removed, run the teardown job also scoped to it.
  lifecycle {
    action_trigger {
      events  = [after_create]
      actions = [action.aap_job_launch.create]
    }
    action_trigger {
      events  = [before_destroy]
      actions = [action.aap_job_launch.destroy]
    }
  }

  # Les règles firewall doivent exister AVANT le job de config (after_create) et
  # survivre JUSQU'À la fin du job de destruction (before_destroy). Comme
  # depends_on s'inverse à la destruction, l'hôte (et ses actions) est traité
  # avant que les règles ne soient supprimées → le SSH reste ouvert.
  # Firewall rules must exist BEFORE the config job (after_create) and survive
  # UNTIL the teardown job finishes (before_destroy). Since depends_on reverses
  # on destroy, the host (and its actions) is handled before the rules are
  # removed → SSH stays open.
  depends_on = [
    aws_security_group.worker,
    aws_security_group_rule.allow_ingress_controller,
    aws_security_group_rule.allow_ingress_controller_httpds,
    aws_security_group_rule.allow_ingress_controller_httpds8080,
    aws_security_group_rule.allow_egress_controller,
  ]
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
      events  = [before_update]
      actions = [action.aap_job_launch.update]
    }
    # create/destroy sont désormais gérés par hôte sur aap_host.host (voir ci-dessus).
    # create/destroy are now handled per-host on aap_host.host (see above).
  }

  # aap_host.host dépend déjà des règles firewall (transitif).
  # aap_host.host already depends on the firewall rules (transitive).
  depends_on = [
    aap_host.host,
  ]
}
