####################################################################
# Outputs
####################################################################

# IPs publiques des serveurs / Public IPs of the servers
output "ec2_all_addr" {
  value = aws_instance.web_server[*].public_ip
}

# URLs HTTP (port 80) / HTTP URLs (port 80)
output "ec2_all_addr_http" {
  value = [for ip in aws_instance.web_server[*].public_ip : "http://${ip}"]
}

# URLs du site servi par AAP (port 8080) / Site URLs served via AAP (port 8080)
output "ec2_all_addr_aap_http" {
  value = [for ip in aws_instance.web_server[*].public_ip : "http://${ip}:8080"]
}

# Détails d'inventaire (attributs choisis pour éviter l'attribut déprécié "variables")
# Inventory details (selected attributes to avoid the deprecated "variables" attribute)
output "inventory_details_with_name_and_org_name" {
  value = {
    id                = data.aap_inventory.my_inventory.id
    name              = data.aap_inventory.my_inventory.name
    organization_name = data.aap_inventory.my_inventory.organization_name
  }
}

# Valeur courante du trigger (debug) / Current trigger value (debug)
output "trigger_input" {
  value = terraform_data.trigger.input
}
