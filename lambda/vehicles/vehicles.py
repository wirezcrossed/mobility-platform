"""
MDS Provider API Vehicles Endpoint
Returns real-time vehicle status data compliant with MDS 2.0
"""

import json
import os
import logging
import boto3
from datetime import datetime, timezone
from typing import Dict, Any, List, Optional
from decimal import Decimal

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Environment variables
DB_SECRET_ARN = os.environ.get('DB_SECRET_ARN')
MDS_VERSION = os.environ.get('MDS_VERSION', '2.0.2')
PROVIDER_ID = os.environ.get('PROVIDER_ID')
PROVIDER_NAME = os.environ.get('PROVIDER_NAME', 'Example Mobility Provider')

# AWS clients
secrets_client = boto3.client('secretsmanager')

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Handle GET /vehicles request
    
    Args:
        event: API Gateway proxy event
        context: Lambda context
        
    Returns:
        API Gateway proxy response
    """
    try:
        logger.info(f"Vehicles request: {json.dumps(event, default=str)}")
        
        # Extract query parameters
        query_params = event.get('queryStringParameters') or {}
        bbox = query_params.get('bbox')
        last_updated = query_params.get('last_updated')
        
        # Get vehicles data
        vehicles_data = get_vehicles(bbox=bbox, last_updated=last_updated)
        
        # Build MDS compliant response
        response_data = {
            'version': MDS_VERSION,
            'data': {
                'vehicles': vehicles_data
            },
            'last_updated': int(datetime.now(timezone.utc).timestamp() * 1000),
            'ttl': 300  # Time to live in seconds
        }
        
        response = {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Cache-Control': 'max-age=300'
            },
            'body': json.dumps(response_data, default=decimal_default)
        }
        
        logger.info(f"Returning {len(vehicles_data)} vehicles")
        return response
        
    except Exception as e:
        logger.error(f"Error processing vehicles request: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Internal server error',
                'message': 'Failed to retrieve vehicles data'
            })
        }

def get_vehicles(bbox: Optional[str] = None, last_updated: Optional[str] = None) -> List[Dict[str, Any]]:
    """
    Get vehicles data from database or generate sample data
    
    Args:
        bbox: Bounding box filter (min_lon,min_lat,max_lon,max_lat)
        last_updated: Unix timestamp for filtering by last update time
        
    Returns:
        List of vehicles in MDS format
    """
    # For demo purposes, return sample data
    # In production, this would query the database
    sample_vehicles = [
        {
            'device_id': 'vehicle_001',
            'provider_id': PROVIDER_ID,
            'data_provider_id': PROVIDER_ID,
            'vehicle_id': 'SCO001',
            'vehicle_type': 'scooter',
            'propulsion_types': ['electric'],
            'vehicle_attributes': {
                'accessible': False
            },
            'vehicle_state': 'available',
            'last_event_types': ['service_start'],
            'last_event_time': int((datetime.now(timezone.utc).timestamp() - 3600) * 1000),
            'last_event_location': {
                'type': 'Point',
                'coordinates': [-122.4194, 37.7749]
            },
            'current_location': {
                'type': 'Point',
                'coordinates': [-122.4194, 37.7749]
            },
            'battery_percent': 85,
            'rental_uris': {
                'android': 'https://example.com/app?vehicle=SCO001',
                'ios': 'https://example.com/app?vehicle=SCO001',
                'web': 'https://example.com/web?vehicle=SCO001'
            }
        },
        {
            'device_id': 'vehicle_002',
            'provider_id': PROVIDER_ID,
            'data_provider_id': PROVIDER_ID,
            'vehicle_id': 'BIK001',
            'vehicle_type': 'bicycle',
            'propulsion_types': ['electric'],
            'vehicle_attributes': {
                'accessible': True
            },
            'vehicle_state': 'reserved',
            'last_event_types': ['reserved'],
            'last_event_time': int((datetime.now(timezone.utc).timestamp() - 300) * 1000),
            'last_event_location': {
                'type': 'Point',
                'coordinates': [-122.4094, 37.7849]
            },
            'current_location': {
                'type': 'Point',
                'coordinates': [-122.4094, 37.7849]
            },
            'battery_percent': 72,
            'rental_uris': {
                'android': 'https://example.com/app?vehicle=BIK001',
                'ios': 'https://example.com/app?vehicle=BIK001',
                'web': 'https://example.com/web?vehicle=BIK001'
            }
        },
        {
            'device_id': 'vehicle_003',
            'provider_id': PROVIDER_ID,
            'data_provider_id': PROVIDER_ID,
            'vehicle_id': 'SCO002',
            'vehicle_type': 'scooter',
            'propulsion_types': ['electric'],
            'vehicle_attributes': {
                'accessible': False
            },
            'vehicle_state': 'on_trip',
            'last_event_types': ['trip_start'],
            'last_event_time': int((datetime.now(timezone.utc).timestamp() - 900) * 1000),
            'last_event_location': {
                'type': 'Point',
                'coordinates': [-122.4294, 37.7649]
            },
            'current_location': {
                'type': 'Point',
                'coordinates': [-122.4294, 37.7649]
            },
            'battery_percent': 45
        },
        {
            'device_id': 'vehicle_004',
            'provider_id': PROVIDER_ID,
            'data_provider_id': PROVIDER_ID,
            'vehicle_id': 'CAR001',
            'vehicle_type': 'car',
            'propulsion_types': ['electric'],
            'vehicle_attributes': {
                'accessible': True,
                'air_quality_unhealthy': False
            },
            'vehicle_state': 'available',
            'last_event_types': ['service_start'],
            'last_event_time': int((datetime.now(timezone.utc).timestamp() - 7200) * 1000),
            'last_event_location': {
                'type': 'Point',
                'coordinates': [-122.4394, 37.7549]
            },
            'current_location': {
                'type': 'Point',
                'coordinates': [-122.4394, 37.7549]
            },
            'battery_percent': 90,
            'rental_uris': {
                'android': 'https://example.com/app?vehicle=CAR001',
                'ios': 'https://example.com/app?vehicle=CAR001',
                'web': 'https://example.com/web?vehicle=CAR001'
            }
        }
    ]
    
    # Apply bbox filter if provided
    if bbox:
        try:
            min_lon, min_lat, max_lon, max_lat = map(float, bbox.split(','))
            filtered_vehicles = []
            for vehicle in sample_vehicles:
                lon, lat = vehicle['current_location']['coordinates']
                if min_lon <= lon <= max_lon and min_lat <= lat <= max_lat:
                    filtered_vehicles.append(vehicle)
            sample_vehicles = filtered_vehicles
        except (ValueError, IndexError):
            logger.warning(f"Invalid bbox format: {bbox}")
    
    # Apply last_updated filter if provided
    if last_updated:
        try:
            last_updated_timestamp = int(last_updated)
            filtered_vehicles = []
            for vehicle in sample_vehicles:
                if vehicle['last_event_time'] >= last_updated_timestamp:
                    filtered_vehicles.append(vehicle)
            sample_vehicles = filtered_vehicles
        except ValueError:
            logger.warning(f"Invalid last_updated format: {last_updated}")
    
    return sample_vehicles

def decimal_default(obj):
    """JSON serializer for objects not serializable by default json code"""
    if isinstance(obj, Decimal):
        return float(obj)
    raise TypeError(f"Object of type {type(obj)} is not JSON serializable")

def get_db_connection():
    """
    Get database connection using credentials from Secrets Manager
    
    Returns:
        Database connection object
    """
    try:
        # Get database credentials from Secrets Manager
        response = secrets_client.get_secret_value(SecretId=DB_SECRET_ARN)
        secret = json.loads(response['SecretString'])
        
        # In a real implementation, you would establish a database connection here
        # import psycopg2
        # conn = psycopg2.connect(
        #     host=secret['host'],
        #     port=secret['port'],
        #     database=secret['dbname'],
        #     user=secret['username'],
        #     password=secret['password']
        # )
        # return conn
        
        return None  # Placeholder for demo
        
    except Exception as e:
        logger.error(f"Failed to get database connection: {str(e)}")
        raise