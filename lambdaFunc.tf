data "archive_file" "lambda" {
  type        = "zip"
  source_file = "index.js"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "lambda_function_payload.zip"
  function_name = "nandanRequestUnicorn"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "nodejs16.x"

}


