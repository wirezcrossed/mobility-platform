# Circuit Provider API Infrastructure

This project implements a Mobility Data Specification (MDS) 2.0 compliant Provider API using Terraform for infrastructure as code. The Circuit Provider API follows the Open Mobility Foundation (OMF) specification for mobility data sharing between cities and mobility providers.

## Overview

The Circuit Provider API enables Circuit and other mobility providers to share real-time data about their vehicles, trips, and events with city agencies for regulation and management of shared mobility services in the public right-of-way.

## Features

- **MDS 2.0 Compliant**: Fully compliant with the latest OMF mobility data specification
- **Multi-modal Support**: Supports micromobility, car share, passenger services, and delivery robots
- **Scalable Infrastructure**: AWS-based infrastructure using API Gateway, Lambda, and RDS
- **Secure Authentication**: Bearer token authentication with proper authorization
- **Real-time Data**: Provides real-time vehicle status, trip data, and event information
- **OpenAPI Specification**: Follows OpenAPI 3.0 standards for API documentation

## Architecture

- **API Gateway**: RESTful API endpoints with authentication and rate limiting
- **AWS Lambda**: Serverless compute for API business logic
- **RDS PostgreSQL**: Managed database for persistent data storage
- **VPC**: Secure network isolation with private subnets
- **CloudWatch**: Monitoring and logging
- **Secrets Manager**: Secure storage of API tokens and database credentials

## API Endpoints

### Core Provider Endpoints (MDS 2.0)
- `GET /vehicles` - Real-time vehicle status
- `GET /trips` - Historical trip data
- `GET /events` - Vehicle event data
- `GET /reports` - Provider reports
- `GET /status` - Service status and health

### Supported Modes
- **Micromobility**: Bikes, e-bikes, scooters, e-scooters
- **Car Share**: Shared cars and light vehicles
- **Passenger Services**: Taxis, ridehail, shuttles
- **Delivery Robots**: Autonomous delivery vehicles

## Deployment

1. Configure AWS credentials
2. Set up environment variables
3. Run Terraform to deploy infrastructure
4. Deploy API code to Lambda functions
5. Configure authentication tokens

## Compliance

This implementation follows:
- MDS 2.0 specification from Open Mobility Foundation
- OpenAPI 3.0 standards
- REST API best practices
- AWS security best practices
- Data privacy and protection requirements

## Documentation

See the `/docs` directory for detailed API documentation, deployment guides, and configuration reference.