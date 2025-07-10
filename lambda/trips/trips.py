"""
Circuit Provider API Trips Endpoint
Returns historical trip data compliant with MDS 2.0
"""

import json
import os
import logging
import boto3
from datetime import datetime, timezone, timedelta
from typing import Dict, Any, List, Optional
from decimal import Decimal
import uuid

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Environment variables
DB_SECRET_ARN = os.environ.get('DB_SECRET_ARN')
MDS_VERSION = os.environ.get('MDS_VERSION', '2.0.2')
PROVIDER_ID = os.environ.get('PROVIDER_ID')
PROVIDER_NAME = os.environ.get('PROVIDER_NAME', 'Circuit Mobility Provider')

# AWS clients
secrets_client = boto3.client('secretsmanager')

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Handle GET /trips request
    
    Args:
        event: API Gateway proxy event
        context: Lambda context
        
    Returns:
        API Gateway proxy response
    """
    try:
        logger.info(f"Trips request: {json.dumps(event, default=str)}")
        
        # Extract required query parameters
        query_params = event.get('queryStringParameters') or {}
        start_time = query_params.get('start_time')
        end_time = query_params.get('end_time')
        bbox = query_params.get('bbox')
        device_id = query_params.get('device_id')
        
        # Validate required parameters
        if not start_time:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'Bad Request',
                    'message': 'start_time parameter is required'
                })
            }
        
        # Get trips data
        trips_data = get_trips(
            start_time=start_time,
            end_time=end_time,
            bbox=bbox,
            device_id=device_id
        )
        
        # Build MDS compliant response
        response_data = {
            'version': MDS_VERSION,
            'data': {
                'trips': trips_data
            },
            'last_updated': int(datetime.now(timezone.utc).timestamp() * 1000),
            'ttl': 3600  # Time to live in seconds
        }
        
        response = {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Cache-Control': 'max-age=3600'
            },
            'body': json.dumps(response_data, default=decimal_default)
        }
        
        logger.info(f"Returning {len(trips_data)} trips")
        return response
        
    except ValueError as e:
        logger.warning(f"Invalid request parameters: {str(e)}")
        return {
            'statusCode': 400,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Bad Request',
                'message': str(e)
            })
        }
    except Exception as e:
        logger.error(f"Error processing trips request: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Internal server error',
                'message': 'Failed to retrieve trips data'
            })
        }

def get_trips(start_time: str, end_time: Optional[str] = None, 
              bbox: Optional[str] = None, device_id: Optional[str] = None) -> List[Dict[str, Any]]:
    """
    Get trips data from database or generate sample data
    
    Args:
        start_time: Unix timestamp for start of time range
        end_time: Unix timestamp for end of time range (optional)
        bbox: Bounding box filter (min_lon,min_lat,max_lon,max_lat)
        device_id: Specific device ID to filter by
        
    Returns:
        List of trips in MDS format
    """
    # Parse timestamps
    try:
        start_timestamp = int(start_time)
        if end_time:
            end_timestamp = int(end_time)
        else:
            # Default to current time if end_time not provided
            end_timestamp = int(datetime.now(timezone.utc).timestamp() * 1000)
    except ValueError:
        raise ValueError("Invalid timestamp format")
    
    # For demo purposes, return sample data
    # In production, this would query the database
    sample_trips = [
        {
            'provider_id': PROVIDER_ID,
            'data_provider_id': PROVIDER_ID,
            'device_id': 'vehicle_001',
            'trip_id': str(uuid.uuid4()),
            'trip_duration': 1245,  # seconds
            'trip_distance': 2340,  # meters
            'route': {
                'type': 'LineString',
                'coordinates': [
                    [-122.4194, 37.7749],
                    [-122.4184, 37.7759],
                    [-122.4174, 37.7769],
                    [-122.4164, 37.7779]
                ]
            },
            'accuracy': 15,
            'start_time': start_timestamp + 3600000,  # 1 hour after start
            'end_time': start_timestamp + 4845000,    # start + duration
            'publication_time': start_timestamp + 4845000,
            'start_location': {
                'type': 'Point',
                'coordinates': [-122.4194, 37.7749]
            },
            'end_location': {
                'type': 'Point',
                'coordinates': [-122.4164, 37.7779]
            },
            'parking_verification_url': 'https://example.com/parking/trip_123',
            'standard_cost': 450,  # cents
            'actual_cost': 400,    # cents
            'currency': 'USD',
            'trip_attributes': {
                'accessibility_type': None,
                'surface_type': 'paved_smooth'
            }
        },
        {
            'provider_id': PROVIDER_ID,
            'data_provider_id': PROVIDER_ID,
            'device_id': 'vehicle_002',
            'trip_id': str(uuid.uuid4()),
            'trip_duration': 892,   # seconds
            'trip_distance': 1580,  # meters
            'route': {
                'type': 'LineString',
                'coordinates': [
                    [-122.4094, 37.7849],
                    [-122.4084, 37.7859],
                    [-122.4074, 37.7869]
                ]
            },
            'accuracy': 12,
            'start_time': start_timestamp + 7200000,  # 2 hours after start
            'end_time': start_timestamp + 8092000,    # start + duration
            'publication_time': start_timestamp + 8092000,
            'start_location': {
                'type': 'Point',
                'coordinates': [-122.4094, 37.7849]
            },
            'end_location': {
                'type': 'Point',
                'coordinates': [-122.4074, 37.7869]
            },
            'standard_cost': 320,  # cents
            'actual_cost': 320,    # cents
            'currency': 'USD',
            'trip_attributes': {
                'accessibility_type': 'wheelchair_accessible',
                'surface_type': 'paved_smooth'
            }
        }
    ]
    
    # Filter by time range
    filtered_trips = []
    for trip in sample_trips:
        if start_timestamp <= trip['start_time'] <= end_timestamp:
            filtered_trips.append(trip)
    
    # Apply bbox filter if provided
    if bbox:
        try:
            min_lon, min_lat, max_lon, max_lat = map(float, bbox.split(','))
            bbox_filtered = []
            for trip in filtered_trips:
                start_lon, start_lat = trip['start_location']['coordinates']
                end_lon, end_lat = trip['end_location']['coordinates']
                
                # Check if either start or end point is within bbox
                if ((min_lon <= start_lon <= max_lon and min_lat <= start_lat <= max_lat) or
                    (min_lon <= end_lon <= max_lon and min_lat <= end_lat <= max_lat)):
                    bbox_filtered.append(trip)
            filtered_trips = bbox_filtered
        except (ValueError, IndexError):
            logger.warning(f"Invalid bbox format: {bbox}")
    
    # Apply device_id filter if provided
    if device_id:
        filtered_trips = [trip for trip in filtered_trips if trip['device_id'] == device_id]
    
    return filtered_trips

def decimal_default(obj):
    """JSON serializer for objects not serializable by default json code"""
    if isinstance(obj, Decimal):
        return float(obj)
    raise TypeError(f"Object of type {type(obj)} is not JSON serializable")