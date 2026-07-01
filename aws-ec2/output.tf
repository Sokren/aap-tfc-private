output "ec2_all_addr" {
  value = aws_instance.web_server[*].public_ip
}

output "ec2_all_addr_http" {
  value = [for ip in aws_instance.web_server[*].public_ip : "http://${ip}"]
}

output "ec2_all_addr_aap_http" {
  value = [for ip in aws_instance.web_server[*].public_ip : "http://${ip}:8080"]
}

output "inventory_details_with_name_and_org_name" {
  value = data.aap_inventory.my_inventory
}

output "trigger_input" {
  value = terraform_data.trigger.input
}