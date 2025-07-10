"""
MDS Provider API Status Endpoint
Returns API status and health information
"""

import json
import os
import logging
from datetime import datetime, timezone
from typing import Dict, Any

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Environment variables
MDS_VERSION = os.environ.get('MDS_VERSION', '2.0.2')
PROVIDER_ID = os.environ.get('PROVIDER_ID')
PROVIDER_NAME = os.environ.get('PROVIDER_NAME', 'Example Mobility Provider')

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Handle GET /status request
    
    Args:
        event: API Gateway proxy event
        context: Lambda context
        
    Returns:
        API Gateway proxy response with API status
    """
    try:
        logger.info(f"Status request: {json.dumps(event, default=str)}")
        
        # Build MDS compliant status response
        current_time = datetime.now(timezone.utc)
        
        status_data = {
            'version': MDS_VERSION,
            'data': {
                'status': {
                    'provider_id': PROVIDER_ID,
                    'provider_name': PROVIDER_NAME,
                    'mds_version': MDS_VERSION,
                    'available_modes': [
                        'micromobility',
                        'car_share'
                    ],
                    'endpoints': {
                        'vehicles': {
                            'available': True,
                            'last_updated': int(current_time.timestamp() * 1000)
                        },
                        'trips': {
                            'available': True,
                            'last_updated': int((current_time.timestamp() - 300) * 1000)
                        },
                        'events': {
                            'available': True,
                            'last_updated': int((current_time.timestamp() - 300) * 1000)
                        },
                        'reports': {
                            'available': True,
                            'last_updated': int((current_time.timestamp() - 3600) * 1000)
                        }
                    },
                    'agency_endpoints': {
                        'gbfs_discovery': 'https://example.com/gbfs.json'
                    },
                    'service_areas': [
                        {
                            'service_area_id': 'sf_downtown',
                            'start_date': '2023-01-01',
                            'end_date': '2025-12-31',
                            'prev_area': None,
                            'replacement_area': None,
                            'geojson': {
                                'type': 'MultiPolygon',
                                'coordinates': [[
                                    [
                                        [-122.5076, 37.7039],
                                        [-122.3482, 37.7039],
                                        [-122.3482, 37.8324],
                                        [-122.5076, 37.8324],
                                        [-122.5076, 37.7039]
                                    ]
                                ]]
                            }
                        }
                    ],
                    'vehicle_types': {
                        'bicycle': {
                            'count': 150,
                            'propulsion_types': ['electric', 'human']
                        },
                        'scooter': {
                            'count': 300,
                            'propulsion_types': ['electric']
                        },
                        'car': {
                            'count': 50,
                            'propulsion_types': ['electric']
                        }
                    },
                    'system_pricing': {
                        'micromobility': {
                            'unlock_fee': 1.00,
                            'per_minute_rate': 0.15,
                            'currency': 'USD'
                        },
                        'car_share': {
                            'unlock_fee': 2.50,
                            'per_minute_rate': 0.45,
                            'currency': 'USD'
                        }
                    }
                }
            },
            'last_updated': int(current_time.timestamp() * 1000),
            'ttl': 3600  # Status TTL in seconds
        }
        
        response = {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Cache-Control': 'max-age=3600'
            },
            'body': json.dumps(status_data)
        }
        
        logger.info("Status request completed successfully")
        return response
        
    except Exception as e:
        logger.error(f"Error processing status request: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Internal server error',
                'message': 'Failed to retrieve status information'
            })
        }

def check_database_health() -> bool:
    """
    Check database connectivity and health
    
    Returns:
        True if database is healthy, False otherwise
    """
    try:
        # In a real implementation, this would check database connectivity
        # For demo purposes, always return True
        return True
    except Exception as e:
        logger.error(f"Database health check failed: {str(e)}")
        return False

def check_external_services() -> Dict[str, bool]:
    """
    Check external service dependencies
    
    Returns:
        Dictionary of service names and their health status
    """
    services = {
        'gbfs_feed': True,  # In production, check actual GBFS feed
        'payment_processor': True,  # Check payment service
        'mapping_service': True  # Check mapping/geocoding service
    }
    
    return services