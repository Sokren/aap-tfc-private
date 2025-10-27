#action "aap_eventdispatch" "create" {
#  config {
#    limit = "tfademo"
#    template_type = "job"
#    job_template_name = "New AWS Provisioning Workflow"
#    organization_name = "Default"
#
#    event_stream_config = {
#      url = var.aap_host_url
#      username = var.aap_username
#      password = var.aap_password
#    }
#  }
#}
#
## TF action to run the update AWS provisioning job (after the hosts get added to AAP inventory)
#action "aap_eventdispatch" "update" {
#  config {
#    limit = "tfademo"
#    template_type = "job"
#    job_template_name = "Update AWS Provisioning Job"
#    organization_name = "Default"
#
#    event_stream_config = {
#      url = var.aap_eventstream_url
#      username = var.aap_username
#      password = var.aap_password
#    }
#  }
#}
