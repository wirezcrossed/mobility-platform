"""
MDS Provider API Authentication Lambda Function
Validates bearer tokens for MDS API access
"""

import json
import os
import logging
from typing import Dict, Any

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Environment variables
MDS_VERSION = os.environ.get('MDS_VERSION', '2.0.2')
PROVIDER_ID = os.environ.get('PROVIDER_ID', '00000000-0000-0000-0000-000000000000')

# Valid tokens for demonstration (in production, use a secure token store)
VALID_TOKENS = {
    'mds-token-12345': {
        'agency_id': 'city-of-example',
        'permissions': ['vehicles:read', 'trips:read', 'events:read', 'reports:read'],
        'rate_limit': 1000
    },
    'mds-token-67890': {
        'agency_id': 'county-transport',
        'permissions': ['vehicles:read', 'trips:read'],
        'rate_limit': 500
    }
}

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    AWS Lambda authorizer function for MDS Provider API
    
    Args:
        event: API Gateway authorizer event
        context: Lambda context
        
    Returns:
        IAM policy document allowing or denying access
    """
    try:
        logger.info(f"Authorization request: {json.dumps(event, default=str)}")
        
        # Extract the authorization token
        token = event.get('authorizationToken', '')
        method_arn = event.get('methodArn', '')
        
        if not token:
            logger.warning("No authorization token provided")
            raise Exception('Unauthorized')
        
        # Remove 'Bearer ' prefix if present
        if token.startswith('Bearer '):
            token = token[7:]
        
        # Validate the token
        token_info = validate_token(token)
        if not token_info:
            logger.warning(f"Invalid token: {token[:10]}...")
            raise Exception('Unauthorized')
        
        # Generate IAM policy
        policy = generate_policy(
            principal_id=token_info['agency_id'],
            effect='Allow',
            resource=method_arn,
            context=token_info
        )
        
        logger.info(f"Authorization successful for agency: {token_info['agency_id']}")
        return policy
        
    except Exception as e:
        logger.error(f"Authorization failed: {str(e)}")
        raise Exception('Unauthorized')

def validate_token(token: str) -> Dict[str, Any]:
    """
    Validate the provided token
    
    Args:
        token: Bearer token to validate
        
    Returns:
        Token information if valid, None otherwise
    """
    if token in VALID_TOKENS:
        return VALID_TOKENS[token]
    return None

def generate_policy(principal_id: str, effect: str, resource: str, context: Dict[str, Any]) -> Dict[str, Any]:
    """
    Generate IAM policy document
    
    Args:
        principal_id: Principal identifier (agency ID)
        effect: Allow or Deny
        resource: ARN of the resource
        context: Additional context to pass to the backend
        
    Returns:
        IAM policy document
    """
    # Extract API Gateway info from resource ARN
    arn_parts = resource.split(':')
    if len(arn_parts) >= 6:
        api_gateway_arn = ':'.join(arn_parts[:5]) + ':*'
    else:
        api_gateway_arn = resource
    
    policy = {
        'principalId': principal_id,
        'policyDocument': {
            'Version': '2012-10-17',
            'Statement': [
                {
                    'Action': 'execute-api:Invoke',
                    'Effect': effect,
                    'Resource': api_gateway_arn
                }
            ]
        },
        'context': {
            'agency_id': context['agency_id'],
            'permissions': ','.join(context['permissions']),
            'rate_limit': str(context['rate_limit']),
            'mds_version': MDS_VERSION,
            'provider_id': PROVIDER_ID
        }
    }
    
    return policy

def get_permissions_for_endpoint(endpoint: str) -> str:
    """
    Get required permission for an endpoint
    
    Args:
        endpoint: API endpoint name
        
    Returns:
        Required permission string
    """
    permission_map = {
        'vehicles': 'vehicles:read',
        'trips': 'trips:read',
        'events': 'events:read',
        'reports': 'reports:read',
        'status': 'status:read'
    }
    return permission_map.get(endpoint, 'unknown:read')