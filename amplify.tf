resource "aws_amplify_app" "web-app" {
  name       = "Nandan-Wildrydes"
  repository = "https://git-codecommit.us-east-1.amazonaws.com/v1/repos/Nandan-Gadhetharia-WildRydes"

  build_spec = <<-EOT
version: 1
frontend:
  phases:
    # IMPORTANT - Please verify your build commands
    build:
      commands: []
  artifacts:
    # IMPORTANT - Please verify your build output directory
    baseDirectory: /
    files:
      - '**/*'
  cache:
    paths: []

EOT

  enable_branch_auto_build = true
  iam_service_role_arn     = aws_iam_role.amplify-codecommit.arn
}

resource "aws_amplify_branch" "master" {
  app_id      = aws_amplify_app.web-app.id
  branch_name = "master"

  # Enable SNS notifications.
  //enable_notification = true
}