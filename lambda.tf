# Lambda Functions for MDS Provider API

# Lambda Function for Authentication
resource "aws_lambda_function" "auth_lambda" {
  filename         = "lambda/auth.zip"
  function_name    = "${var.project_name}-auth"
  role            = aws_iam_role.lambda_role.arn
  handler         = "auth.lambda_handler"
  source_code_hash = data.archive_file.auth_zip.output_base64sha256
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size

  environment {
    variables = {
      MDS_VERSION = var.mds_version
      PROVIDER_ID = var.provider_id
    }
  }

  tags = {
    Name = "${var.project_name}-auth-lambda"
  }
}

# Lambda Function for Vehicles endpoint
resource "aws_lambda_function" "vehicles_lambda" {
  filename         = "lambda/vehicles.zip"
  function_name    = "${var.project_name}-vehicles"
  role            = aws_iam_role.lambda_role.arn
  handler         = "vehicles.lambda_handler"
  source_code_hash = data.archive_file.vehicles_zip.output_base64sha256
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size

  vpc_config {
    subnet_ids         = aws_subnet.private_subnet[*].id
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      DB_SECRET_ARN = aws_secretsmanager_secret.db_credentials.arn
      MDS_VERSION   = var.mds_version
      PROVIDER_ID   = var.provider_id
      PROVIDER_NAME = var.provider_name
    }
  }

  tags = {
    Name = "${var.project_name}-vehicles-lambda"
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_vpc_policy,
    aws_cloudwatch_log_group.vehicles_lambda_logs
  ]
}

# Lambda Function for Trips endpoint
resource "aws_lambda_function" "trips_lambda" {
  filename         = "lambda/trips.zip"
  function_name    = "${var.project_name}-trips"
  role            = aws_iam_role.lambda_role.arn
  handler         = "trips.lambda_handler"
  source_code_hash = data.archive_file.trips_zip.output_base64sha256
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size

  vpc_config {
    subnet_ids         = aws_subnet.private_subnet[*].id
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      DB_SECRET_ARN = aws_secretsmanager_secret.db_credentials.arn
      MDS_VERSION   = var.mds_version
      PROVIDER_ID   = var.provider_id
      PROVIDER_NAME = var.provider_name
    }
  }

  tags = {
    Name = "${var.project_name}-trips-lambda"
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_vpc_policy,
    aws_cloudwatch_log_group.trips_lambda_logs
  ]
}

# Lambda Function for Events endpoint
resource "aws_lambda_function" "events_lambda" {
  filename         = "lambda/events.zip"
  function_name    = "${var.project_name}-events"
  role            = aws_iam_role.lambda_role.arn
  handler         = "events.lambda_handler"
  source_code_hash = data.archive_file.events_zip.output_base64sha256
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size

  vpc_config {
    subnet_ids         = aws_subnet.private_subnet[*].id
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      DB_SECRET_ARN = aws_secretsmanager_secret.db_credentials.arn
      MDS_VERSION   = var.mds_version
      PROVIDER_ID   = var.provider_id
      PROVIDER_NAME = var.provider_name
    }
  }

  tags = {
    Name = "${var.project_name}-events-lambda"
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_vpc_policy,
    aws_cloudwatch_log_group.events_lambda_logs
  ]
}

# Lambda Function for Reports endpoint
resource "aws_lambda_function" "reports_lambda" {
  filename         = "lambda/reports.zip"
  function_name    = "${var.project_name}-reports"
  role            = aws_iam_role.lambda_role.arn
  handler         = "reports.lambda_handler"
  source_code_hash = data.archive_file.reports_zip.output_base64sha256
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size

  vpc_config {
    subnet_ids         = aws_subnet.private_subnet[*].id
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      DB_SECRET_ARN = aws_secretsmanager_secret.db_credentials.arn
      MDS_VERSION   = var.mds_version
      PROVIDER_ID   = var.provider_id
      PROVIDER_NAME = var.provider_name
    }
  }

  tags = {
    Name = "${var.project_name}-reports-lambda"
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_vpc_policy,
    aws_cloudwatch_log_group.reports_lambda_logs
  ]
}

# Lambda Function for Status endpoint
resource "aws_lambda_function" "status_lambda" {
  filename         = "lambda/status.zip"
  function_name    = "${var.project_name}-status"
  role            = aws_iam_role.lambda_role.arn
  handler         = "status.lambda_handler"
  source_code_hash = data.archive_file.status_zip.output_base64sha256
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size

  environment {
    variables = {
      MDS_VERSION   = var.mds_version
      PROVIDER_ID   = var.provider_id
      PROVIDER_NAME = var.provider_name
    }
  }

  tags = {
    Name = "${var.project_name}-status-lambda"
  }

  depends_on = [
    aws_cloudwatch_log_group.status_lambda_logs
  ]
}

# Archive data sources for Lambda deployment packages
data "archive_file" "auth_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/auth"
  output_path = "${path.module}/lambda/auth.zip"
}

data "archive_file" "vehicles_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/vehicles"
  output_path = "${path.module}/lambda/vehicles.zip"
}

data "archive_file" "trips_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/trips"
  output_path = "${path.module}/lambda/trips.zip"
}

data "archive_file" "events_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/events"
  output_path = "${path.module}/lambda/events.zip"
}

data "archive_file" "reports_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/reports"
  output_path = "${path.module}/lambda/reports.zip"
}

data "archive_file" "status_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/status"
  output_path = "${path.module}/lambda/status.zip"
}

# Lambda Permissions for API Gateway
resource "aws_lambda_permission" "auth_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.mds_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "vehicles_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.vehicles_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.mds_api.execution_arn}/*/GET/vehicles"
}

resource "aws_lambda_permission" "trips_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.trips_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.mds_api.execution_arn}/*/GET/trips"
}

resource "aws_lambda_permission" "events_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.events_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.mds_api.execution_arn}/*/GET/events"
}

resource "aws_lambda_permission" "reports_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.reports_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.mds_api.execution_arn}/*/GET/reports"
}

resource "aws_lambda_permission" "status_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.status_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.mds_api.execution_arn}/*/GET/status"
}

# CloudWatch Log Groups for Lambda functions
resource "aws_cloudwatch_log_group" "auth_lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-auth"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "vehicles_lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-vehicles"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "trips_lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-trips"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "events_lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-events"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "reports_lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-reports"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "status_lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-status"
  retention_in_days = var.log_retention_days
}