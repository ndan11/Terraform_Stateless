output "git-user-name" {
  value     = aws_iam_service_specific_credential.shrey_HTTPS_credentials.service_user_name
  sensitive = false
}

output "git-password" {
  value     = nonsensitive(aws_iam_service_specific_credential.shrey_HTTPS_credentials.service_password)
  sensitive = false
}

output "api-invoke-url" {
    value = aws_api_gateway_deployment.deployment.invoke_url
}