resource "aws_iam_user" "nandan_IAM_user" {
  name = "nandan-git"
}

resource "aws_iam_user_policy_attachment" "nandan_user_policy_attachment" {
  user       = aws_iam_user.nandan_IAM_user.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess"
}

resource "aws_iam_service_specific_credential" "nandan_HTTPS_credentials" {
  service_name = "codecommit.amazonaws.com"
  user_name    = aws_iam_user.nandan_IAM_user.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["amplify.amazonaws.com"]
    }
  }
}
#IAM role providing read-only access to CodeCommit
resource "aws_iam_role" "amplify-codecommit" {
  name                = "Codecommit-amplify"
  assume_role_policy  = join("", data.aws_iam_policy_document.assume_role.*.json)
  managed_policy_arns = ["arn:aws:iam::aws:policy/AWSCodeCommitReadOnly"]
}

resource "aws_iam_role" "lambda_role" {
  name = "Nandan-WildRydesLambda-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "lambda.amazonaws.com"
      },
      "Action" : "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "db_policy" {
  name = "DynamoDBWriteAccess"
  //role = aws_iam_role.lambda_role.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : "dynamodb:PutItem",
          "Resource" : "your-arn"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "lambda-policy1" {
  role       = aws_iam_role.lambda_role.name
  depends_on = [
    aws_iam_role.lambda_role
  ]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda-policy2" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "${aws_iam_policy.db_policy.arn}"
}