resource "aws_api_gateway_rest_api" "rest-api" {
  name = "Nandan"
  endpoint_configuration {
    types = ["EDGE"]
  }
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.rest-api.id
  parent_id   = aws_api_gateway_rest_api.rest-api.root_resource_id
  path_part   = "ride"
}

resource "aws_api_gateway_authorizer" "auth" {
  name          = "Cognito"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.rest-api.id
  provider_arns = ["arn:aws:cognito-idp:us-east-1:587172484624:userpool/us-east-1_kB8zcPaXr"]
}

//---------------------------OPTIONS--------------------------------
resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.rest-api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest-api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "OPTIONS"
  content_handling        = "CONVERT_TO_TEXT"
  type                    = "MOCK"
  uri                     = aws_lambda_function.test_lambda.invoke_arn
  request_templates       = { "application/json" = "{ \"statusCode\": 200 }" }
}

resource "aws_api_gateway_integration_response" "integration-response" {
  rest_api_id = aws_api_gateway_rest_api.rest-api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.method.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET,POST,PUT'"
  }
  
  depends_on = [aws_api_gateway_integration.integration]
}

resource "aws_api_gateway_method_response" "method-response" {
  rest_api_id = aws_api_gateway_rest_api.rest-api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.method.http_method

  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [
    aws_api_gateway_integration.integration
  ]
}


//--------------------------------POST----------------------------------
resource "aws_api_gateway_method" "method1" {
  rest_api_id   = aws_api_gateway_rest_api.rest-api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "ANY"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.auth.id
}

resource "aws_api_gateway_method_response" "method-response1" {
  rest_api_id = aws_api_gateway_rest_api.rest-api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.method1.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "integration-response1" {
  rest_api_id        = aws_api_gateway_rest_api.rest-api.id
  resource_id        = aws_api_gateway_resource.resource.id
  http_method        = aws_api_gateway_method.method1.http_method
  status_code        = aws_api_gateway_method_response.method-response1.status_code
  response_templates = { "application/json" = "" }
  depends_on         = [aws_api_gateway_integration.integration1]
}

resource "aws_api_gateway_integration" "integration1" {
  rest_api_id             = aws_api_gateway_rest_api.rest-api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method1.http_method
  integration_http_method = "ANY"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.test_lambda.invoke_arn
}



//-------------------------------DEPLOYMENT-----------------------------------
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest-api.id
  stage_name  = "prod"

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.resource.id,
      aws_api_gateway_method.method1.id,
      aws_api_gateway_integration.integration1.id,
    ]))
  }
}

# resource "aws_api_gateway_model" "empty" { 
#     rest_api_id = aws_api_gateway_rest_api.rest-api.id 
#     name = "Empty" 
#     description = "This is a default empty schema mode" 
#     content_type = "application/json" 
#     schema = "{\n \"$schema\": \"http://json-schema.org/draft-04/schema#\",\n \"title\": \"Empty Schema\",\n \"type\": \"object\"\n}" 
# }

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:us-east-1:587172484624:${aws_api_gateway_rest_api.rest-api.id}/*/*/ride"
}
