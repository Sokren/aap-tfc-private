# # Affichage des résultats de la requete http
# output "response_status" {
#   value = data.http.post_request.status_code
# }

 output "Status AAP" {
   value = data.aap_job.run_job_template
 }