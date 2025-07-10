# MDS Provider API Deployment Guide

This guide explains how to deploy and configure the MDS Provider API infrastructure using Terraform on AWS.

## Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.0 installed
- AWS CLI configured with credentials
- Basic understanding of MDS (Mobility Data Specification)

## Quick Start

1. **Clone and configure the project:**
   ```bash
   git clone <repository-url>
   cd mds-provider-api
   ```

2. **Configure variables:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your specific values
   ```

3. **Deploy infrastructure:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration

### Required Variables

Create a `terraform.tfvars` file with the following variables:

```hcl
# Basic Configuration
aws_region     = "us-west-2"
environment    = "dev"
project_name   = "mds-provider-api"

# MDS Configuration
provider_id     = "your-uuid-here"
provider_name   = "Your Mobility Provider"
mds_version     = "2.0.2"

# Network Configuration
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b"]

# Database Configuration
database_name         = "mds_provider"
database_username     = "mds_admin"
postgres_version      = "15.4"
db_instance_class     = "db.t3.micro"
db_allocated_storage  = 20

# Lambda Configuration
lambda_timeout     = 30
lambda_memory_size = 256
lambda_runtime     = "python3.11"

# API Configuration
api_throttle_rate_limit  = 2000
api_throttle_burst_limit = 5000
enable_api_key_auth      = true

# Monitoring
enable_detailed_monitoring = true
log_retention_days        = 14
```

### Environment-Specific Configuration

#### Development Environment
```hcl
environment = "dev"
db_instance_class = "db.t3.micro"
lambda_memory_size = 256
log_retention_days = 7
```

#### Production Environment
```hcl
environment = "prod"
db_instance_class = "db.r5.large"
lambda_memory_size = 512
log_retention_days = 30
db_allocated_storage = 100
db_max_allocated_storage = 500
```

## Deployment Steps

### 1. Initialize Terraform

```bash
terraform init
```

This command downloads the required providers and modules.

### 2. Plan Deployment

```bash
terraform plan -var-file="terraform.tfvars"
```

Review the planned changes to ensure they match your expectations.

### 3. Apply Configuration

```bash
terraform apply -var-file="terraform.tfvars"
```

Type `yes` when prompted to confirm the deployment.

### 4. Note the Outputs

After successful deployment, Terraform will output important information:

```bash
# API Gateway URL
api_gateway_url = "https://abc123.execute-api.us-west-2.amazonaws.com/dev"

# API Endpoints
api_endpoints = {
  vehicles = "https://abc123.execute-api.us-west-2.amazonaws.com/dev/vehicles"
  trips    = "https://abc123.execute-api.us-west-2.amazonaws.com/dev/trips"
  events   = "https://abc123.execute-api.us-west-2.amazonaws.com/dev/events"
  reports  = "https://abc123.execute-api.us-west-2.amazonaws.com/dev/reports"
  status   = "https://abc123.execute-api.us-west-2.amazonaws.com/dev/status"
}

# Database endpoint (sensitive)
database_endpoint = <sensitive>

# Other configuration details...
```

## Authentication Setup

### API Tokens

The API uses bearer token authentication. Valid tokens are currently configured in the Lambda authorizer function. To add new tokens:

1. Edit `lambda/auth/auth.py`
2. Add new tokens to the `VALID_TOKENS` dictionary
3. Redeploy the auth Lambda function

Example token configuration:
```python
VALID_TOKENS = {
    'mds-token-12345': {
        'agency_id': 'city-of-example',
        'permissions': ['vehicles:read', 'trips:read', 'events:read', 'reports:read'],
        'rate_limit': 1000
    }
}
```

### Making Authenticated Requests

Include the bearer token in the Authorization header:

```bash
curl -H "Authorization: Bearer mds-token-12345" \
     https://your-api-url/vehicles
```

## Database Setup

### Initial Schema

The RDS PostgreSQL database is created automatically, but you'll need to create the initial schema. Connect to the database and run:

```sql
-- Example tables for MDS data
CREATE TABLE vehicles (
    device_id VARCHAR(255) PRIMARY KEY,
    provider_id UUID NOT NULL,
    vehicle_id VARCHAR(255) NOT NULL,
    vehicle_type VARCHAR(50) NOT NULL,
    vehicle_state VARCHAR(50) NOT NULL,
    current_location JSONB NOT NULL,
    battery_percent INTEGER,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE trips (
    trip_id UUID PRIMARY KEY,
    provider_id UUID NOT NULL,
    device_id VARCHAR(255) NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    trip_duration INTEGER NOT NULL,
    trip_distance INTEGER NOT NULL,
    start_location JSONB NOT NULL,
    end_location JSONB NOT NULL,
    route JSONB,
    standard_cost INTEGER,
    actual_cost INTEGER,
    currency VARCHAR(3) DEFAULT 'USD'
);

CREATE TABLE events (
    event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_id UUID NOT NULL,
    device_id VARCHAR(255) NOT NULL,
    event_types TEXT[] NOT NULL,
    event_time TIMESTAMP WITH TIME ZONE NOT NULL,
    event_location JSONB NOT NULL,
    battery_percent INTEGER,
    associated_trip UUID REFERENCES trips(trip_id)
);

-- Create indexes for performance
CREATE INDEX idx_vehicles_provider_id ON vehicles(provider_id);
CREATE INDEX idx_trips_provider_id ON trips(provider_id);
CREATE INDEX idx_trips_start_time ON trips(start_time);
CREATE INDEX idx_events_provider_id ON events(provider_id);
CREATE INDEX idx_events_event_time ON events(event_time);
```

### Database Connection

To connect to the database:

1. Get the database endpoint from Terraform outputs
2. Retrieve credentials from AWS Secrets Manager
3. Use any PostgreSQL client to connect

```bash
# Get database credentials
aws secretsmanager get-secret-value \
    --secret-id mds-provider-api-db-credentials \
    --query SecretString --output text | jq -r .
```

## API Testing

### Test Status Endpoint

```bash
curl https://your-api-url/status
```

### Test Vehicles Endpoint

```bash
curl -H "Authorization: Bearer mds-token-12345" \
     "https://your-api-url/vehicles?bbox=-122.5,37.7,-122.3,37.8"
```

### Test Trips Endpoint

```bash
curl -H "Authorization: Bearer mds-token-12345" \
     "https://your-api-url/trips?start_time=1642694400000"
```

## Monitoring and Logs

### CloudWatch Logs

All Lambda functions log to CloudWatch. Access logs via:

- AWS Console: CloudWatch > Log groups
- AWS CLI: `aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/mds-provider-api"`

### API Gateway Logs

API Gateway access logs are available in CloudWatch under:
- Log group: `/aws/apigateway/mds-provider-api`

### Monitoring Dashboards

Consider setting up CloudWatch dashboards to monitor:
- API Gateway request count and latency
- Lambda function duration and errors
- RDS database performance
- Error rates and response times

## Troubleshooting

### Common Issues

1. **Lambda timeout errors**
   - Increase `lambda_timeout` variable
   - Check VPC networking configuration

2. **Database connection errors**
   - Verify security group rules
   - Check RDS instance status
   - Validate database credentials

3. **Authentication failures**
   - Verify bearer token format
   - Check Lambda authorizer logs
   - Ensure token is in VALID_TOKENS dictionary

4. **CORS errors**
   - Verify CORS configuration in API Gateway
   - Check `cors_allowed_origins` variable

### Debug Commands

```bash
# Check Terraform state
terraform state list

# View Lambda function logs
aws logs tail /aws/lambda/mds-provider-api-vehicles --follow

# Test database connectivity
aws rds describe-db-instances --db-instance-identifier mds-provider-api-database

# Check API Gateway deployment
aws apigateway get-deployments --rest-api-id <api-id>
```

## Scaling Considerations

### Performance Optimization

1. **Database optimization:**
   - Increase RDS instance size for production
   - Enable read replicas for heavy read workloads
   - Optimize database indexes

2. **Lambda optimization:**
   - Increase memory allocation for better CPU performance
   - Implement connection pooling for database connections
   - Use Lambda provisioned concurrency for consistent performance

3. **API Gateway optimization:**
   - Enable caching for frequently accessed endpoints
   - Implement request/response compression
   - Use custom domain names with CloudFront

### High Availability

1. **Multi-AZ deployment:**
   - Deploy RDS in multiple availability zones
   - Use multiple subnets across AZs

2. **Backup and recovery:**
   - Enable automated RDS backups
   - Implement Lambda function versioning
   - Store deployment artifacts in S3

## Security Best Practices

1. **Network Security:**
   - Keep RDS in private subnets
   - Use security groups with minimal required access
   - Enable VPC Flow Logs

2. **Data Security:**
   - Enable RDS encryption at rest
   - Use TLS for all API communications
   - Implement proper IAM roles and policies

3. **Access Control:**
   - Regularly rotate API tokens
   - Implement principle of least privilege
   - Monitor access patterns

4. **Compliance:**
   - Follow MDS privacy guidelines
   - Implement data retention policies
   - Ensure GDPR compliance if applicable

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy -var-file="terraform.tfvars"
```

**Warning:** This will permanently delete all resources including the database and all data.

## Support

For issues related to:
- MDS specification: [Open Mobility Foundation](https://www.openmobilityfoundation.org/)
- AWS services: [AWS Support](https://aws.amazon.com/support/)
- This implementation: See project documentation and issues

## License

This project is licensed under the MIT License - see the LICENSE file for details.