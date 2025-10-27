locals {
  webserver_urls = [for ip in aws_instance.web_server[*].public_ip : "http://${ip}:8080"]
}

check "health_check_http_AAP_8080" {
  for_each = toset(local.webserver_urls)

  data "http" "apache2_AAP" {
    url = each.key
  }

  assert {
    condition     = data.http.apache2_AAP.status_code == 200
    error_message = "${data.http.apache2_AAP.url} returned an unhealthy status code"
  }
}