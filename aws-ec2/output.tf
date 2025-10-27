output "ec2_first_addr" {
  value = aws_instance.web_server.public_ip
}

output "ec2_first_addr_http" {
  value = "http://${aws_instance.web_server.public_ip}"
}

output "ec2_first_addr_aap_http" {
  value = "http://${aws_instance.web_server.public_ip}:8080"
}