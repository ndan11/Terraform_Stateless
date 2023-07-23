resource "aws_cognito_user_pool" "nandan-user-pool" {

  name = "Nandan-Wildrydes"
  auto_verified_attributes = [ "email" ]
  user_attribute_update_settings {
    attributes_require_verification_before_update = [ "email" ]
  }

  email_configuration {
    email_sending_account = "DEVELOPER"
    from_email_address    = "ndan11gadhetharia@gmail.com"
    source_arn            = "arn:aws:ses:us-east-1:587172484624:identity/ndan11gadhetharia@gmail.com"
  }

  mfa_configuration = "OFF"

  tags = {
    Owner = "Nandan"
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name = "nandan-app-client"
  user_pool_id = aws_cognito_user_pool.nandan-user-pool.id
}