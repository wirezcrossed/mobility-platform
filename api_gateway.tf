# API Gateway Resources for Circuit Provider API Endpoints

# API Gateway Authorizer for Bearer Token Authentication
resource "aws_api_gateway_authorizer" "mds_authorizer" {
  name                   = "${var.project_name}-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.mds_api.id
  authorizer_uri         = aws_lambda_function.auth_lambda.invoke_arn
  authorizer_credentials = aws_iam_role.api_gateway_authorizer_role.arn
  type                   = "TOKEN"
  identity_source        = "method.request.header.Authorization"
}

# IAM Role for API Gateway Authorizer
resource "aws_iam_role" "api_gateway_authorizer_role" {
  name = "${var.project_name}-api-gateway-authorizer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "api_gateway_authorizer_policy" {
  name = "${var.project_name}-api-gateway-authorizer-policy"
  role = aws_iam_role.api_gateway_authorizer_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = aws_lambda_function.auth_lambda.arn
      }
    ]
  })
}

# CORS Resource
resource "aws_api_gateway_method" "options_method" {
  for_each = toset(["vehicles", "trips", "events", "reports", "status"])
  
  rest_api_id   = aws_api_gateway_rest_api.mds_api.id
  resource_id   = aws_api_gateway_resource.mds_resource[each.key].id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_integration" {
  for_each = toset(["vehicles", "trips", "events", "reports", "status"])
  
  rest_api_id = aws_api_gateway_rest_api.mds_api.id
  resource_id = aws_api_gateway_resource.mds_resource[each.key].id
  http_method = aws_api_gateway_method.options_method[each.key].http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_response" {
  for_each = toset(["vehicles", "trips", "events", "reports", "status"])
  
  rest_api_id = aws_api_gateway_rest_api.mds_api.id
  resource_id = aws_api_gateway_resource.mds_resource[each.key].id
  http_method = aws_api_gateway_method.options_method[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  for_each = toset(["vehicles", "trips", "events", "reports", "status"])
  
  rest_api_id = aws_api_gateway_rest_api.mds_api.id
  resource_id = aws_api_gateway_resource.mds_resource[each.key].id
  http_method = aws_api_gateway_method.options_method[each.key].http_method
  status_code = aws_api_gateway_method_response.options_response[each.key].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# API Gateway Resources
resource "aws_api_gateway_resource" "mds_resource" {
  for_each = toset(["vehicles", "trips", "events", "reports", "status"])
  
  rest_api_id = aws_api_gateway_rest_api.mds_api.id
  parent_id   = aws_api_gateway_rest_api.mds_api.root_resource_id
  path_part   = each.key
}

# GET Methods for each endpoint
resource "aws_api_gateway_method" "vehicles_get" {
  rest_api_id   = aws_api_gateway_rest_api.mds_api.id
  resource_id   = aws_api_gateway_resource.mds_resource["vehicles"].id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.mds_authorizer.id

  request_parameters = {
    "method.request.querystring.bbox"         = false
    "method.request.querystring.last_updated" = false
  }
}

resource "aws_api_gateway_method" "trips_get" {
  rest_api_id   = aws_api_gateway_rest_api.mds_api.id
  resource_id   = aws_api_gateway_resource.mds_resource["trips"].id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.mds_authorizer.id

  request_parameters = {
    "method.request.querystring.start_time" = true
    "method.request.querystring.end_time"   = false
    "method.request.querystring.bbox"       = false
    "method.request.querystring.device_id"  = false
  }
}

resource "aws_api_gateway_method" "events_get" {
  rest_api_id   = aws_api_gateway_rest_api.mds_api.id
  resource_id   = aws_api_gateway_resource.mds_resource["events"].id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.mds_authorizer.id

  request_parameters = {
    "method.request.querystring.start_time" = true
    "method.request.querystring.end_time"   = false
    "method.request.querystring.bbox"       = false
    "method.request.querystring.device_id"  = false
  }
}

resource "aws_api_gateway_method" "reports_get" {
  rest_api_id   = aws_api_gateway_rest_api.mds_api.id
  resource_id   = aws_api_gateway_resource.mds_resource["reports"].id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.mds_authorizer.id

  request_parameters = {
    "method.request.querystring.start_date" = true
    "method.request.querystring.end_date"   = false
  }
}

resource "aws_api_gateway_method" "status_get" {
  rest_api_id   = aws_api_gateway_rest_api.mds_api.id
  resource_id   = aws_api_gateway_resource.mds_resource["status"].id
  http_method   = "GET"
  authorization = "NONE"  # Status endpoint typically doesn't require auth
}

# Lambda Integrations
resource "aws_api_gateway_integration" "vehicles_integration" {
  rest_api_id = aws_api_gateway_rest_api.mds_api.id
  resource_id = aws_api_gateway_resource.mds_resource["vehicles"].id
  http_method = aws_api_gateway_method.vehicles_get.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.vehicles_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "trips_integration" {
  rest_api_id = aws_api_gateway_rest_api.mds_api.id
  resource_id = aws_api_gateway_resource.mds_resource["trips"].id
  http_method = aws_api_gateway_method.trips_get.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.trips_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "events_integration" {
  rest_api_id = aws_api_gateway_rest_api.mds_api.id
  resource_id = aws_api_gateway_resource.mds_resource["events"].id
  http_method = aws_api_gateway_method.events_get.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.events_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "reports_integration" {
  rest_api_id = aws_api_gateway_rest_api.mds_api.id
  resource_id = aws_api_gateway_resource.mds_resource["reports"].id
  http_method = aws_api_gateway_method.reports_get.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.reports_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "status_integration" {
  rest_api_id = aws_api_gateway_rest_api.mds_api.id
  resource_id = aws_api_gateway_resource.mds_resource["status"].id
  http_method = aws_api_gateway_method.status_get.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.status_lambda.invoke_arn
}

# Method Responses
resource "aws_api_gateway_method_response" "vehicles_response" {
  rest_api_id = aws_api_gateway_rest_api.mds_api.id
  resource_id = aws_api_gateway_resource.mds_resource["vehicles"].id
  http_method = aws_api_gateway_method.vehicles_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "trips_response" {
  rest_api_id = aws_api_gateway_rest_api.mds_api.id
  resource_id = aws_api_gateway_resource.mds_resource["trips"].id
  http_method = aws_api_gateway_method.trips_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "events_response" {
  rest_api_id = aws_api_gateway_rest_api.mds_api.id
  resource_id = aws_api_gateway_resource.mds_resource["events"].id
  http_method = aws_api_gateway_method.events_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "reports_response" {
  rest_api_id = aws_api_gateway_rest_api.mds_api.id
  resource_id = aws_api_gateway_resource.mds_resource["reports"].id
  http_method = aws_api_gateway_method.reports_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "status_response" {
  rest_api_id = aws_api_gateway_rest_api.mds_api.id
  resource_id = aws_api_gateway_resource.mds_resource["status"].id
  http_method = aws_api_gateway_method.status_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# Request Validators
resource "aws_api_gateway_request_validator" "mds_validator" {
  name                        = "${var.project_name}-request-validator"
  rest_api_id                 = aws_api_gateway_rest_api.mds_api.id
  validate_request_body       = true
  validate_request_parameters = true
}

# Usage Plan for API Throttling
resource "aws_api_gateway_usage_plan" "mds_usage_plan" {
  name = "${var.project_name}-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.mds_api.id
    stage  = aws_api_gateway_stage.mds_api_stage.stage_name
  }

  quota_settings {
    limit  = 10000
    period = "DAY"
  }

  throttle_settings {
    rate_limit  = var.api_throttle_rate_limit
    burst_limit = var.api_throttle_burst_limit
  }
}

# API Key for usage plan
resource "aws_api_gateway_api_key" "mds_api_key" {
  count = var.enable_api_key_auth ? 1 : 0
  name  = "${var.project_name}-api-key"
}

resource "aws_api_gateway_usage_plan_key" "mds_usage_plan_key" {
  count         = var.enable_api_key_auth ? 1 : 0
  key_id        = aws_api_gateway_api_key.mds_api_key[0].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.mds_usage_plan.id
}