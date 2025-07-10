# Outputs for Circuit Provider API Infrastructure

output "api_gateway_url" {
  description = "Base URL for the Circuit Provider API"
  value       = "https://${aws_api_gateway_rest_api.mds_api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.environment}"
}

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.mds_api.id
}

output "api_endpoints" {
  description = "Circuit Provider API endpoint URLs"
  value = {
    vehicles = "https://${aws_api_gateway_rest_api.mds_api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.environment}/vehicles"
    trips    = "https://${aws_api_gateway_rest_api.mds_api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.environment}/trips"
    events   = "https://${aws_api_gateway_rest_api.mds_api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.environment}/events"
    reports  = "https://${aws_api_gateway_rest_api.mds_api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.environment}/reports"
    status   = "https://${aws_api_gateway_rest_api.mds_api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.environment}/status"
  }
}

output "database_endpoint" {
  description = "RDS PostgreSQL database endpoint"
  value       = aws_db_instance.mds_database.endpoint
  sensitive   = true
}

output "database_port" {
  description = "RDS PostgreSQL database port"
  value       = aws_db_instance.mds_database.port
}

output "database_name" {
  description = "Name of the PostgreSQL database"
  value       = aws_db_instance.mds_database.db_name
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.mds_vpc.id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private_subnet[*].id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public_subnet[*].id
}

output "lambda_functions" {
  description = "Lambda function ARNs"
  value = {
    auth     = aws_lambda_function.auth_lambda.arn
    vehicles = aws_lambda_function.vehicles_lambda.arn
    trips    = aws_lambda_function.trips_lambda.arn
    events   = aws_lambda_function.events_lambda.arn
    reports  = aws_lambda_function.reports_lambda.arn
    status   = aws_lambda_function.status_lambda.arn
  }
}

output "secrets_manager_secret_arn" {
  description = "ARN of the Secrets Manager secret containing database credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
  sensitive   = true
}

output "api_key_id" {
  description = "API Key ID (if enabled)"
  value       = var.enable_api_key_auth ? aws_api_gateway_api_key.mds_api_key[0].id : null
}

output "mds_configuration" {
  description = "MDS configuration details"
  value = {
    version        = var.mds_version
    provider_id    = var.provider_id
    provider_name  = var.provider_name
    supported_modes = var.supported_modes
  }
}

output "cloudwatch_log_groups" {
  description = "CloudWatch log group names"
  value = {
    api_gateway = aws_cloudwatch_log_group.api_gateway_logs.name
    auth        = aws_cloudwatch_log_group.auth_lambda_logs.name
    vehicles    = aws_cloudwatch_log_group.vehicles_lambda_logs.name
    trips       = aws_cloudwatch_log_group.trips_lambda_logs.name
    events      = aws_cloudwatch_log_group.events_lambda_logs.name
    reports     = aws_cloudwatch_log_group.reports_lambda_logs.name
    status      = aws_cloudwatch_log_group.status_lambda_logs.name
  }
}

output "security_group_ids" {
  description = "Security group IDs"
  value = {
    lambda_sg = aws_security_group.lambda_sg.id
    rds_sg    = aws_security_group.rds_sg.id
  }
}

output "deployment_info" {
  description = "Deployment information"
  value = {
    environment    = var.environment
    project_name   = var.project_name
    aws_region     = var.aws_region
    deployment_url = "https://${aws_api_gateway_rest_api.mds_api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.environment}"
  }
}