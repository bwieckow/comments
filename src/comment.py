import json
import boto3
from botocore.exceptions import ClientError
from datetime import datetime, timezone  # Import timezone

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('comments')

def validate_input(event, required_fields):
    for field in required_fields:
        if field not in event:
            return False, f"Missing required field: {field}"
    return True, None

def get_comments(event):
    is_valid, error_message = validate_input(event, ['start_date', 'end_date'])
    if not is_valid:
        return {
            'statusCode': 400,
            'body': json.dumps(error_message)
        }

    start_date = event['start_date']
    end_date = event['end_date']
    
    try:
        response = table.scan(
            FilterExpression="comment_date BETWEEN :start_date AND :end_date",
            ExpressionAttributeValues={
                ":start_date": start_date,
                ":end_date": end_date
            }
        )
        return {
            'statusCode': 200,
            'body': json.dumps(response['Items'])
        }
    except ClientError as e:
        return {
            'statusCode': 500,
            'body': json.dumps('Internal server error')
        }

def post_comment(event):
    is_valid, error_message = validate_input(event, ['comment_id', 'user_id', 'comment_text'])
    if not is_valid:
        return {
            'statusCode': 400,
            'body': json.dumps(error_message)
        }

    comment_id = event['comment_id']
    user_id = event['user_id']
    comment_text = event['comment_text']
    comment_date = datetime.now(timezone.utc).isoformat()  # Use timezone.utc
    
    try:
        response = table.put_item(
            Item={
                'comment_id': comment_id,
                'user_id': user_id,
                'comment_text': comment_text,
                'comment_date': comment_date
            },
            ConditionExpression='attribute_not_exists(user_id)'
        )
        return {
            'statusCode': 200,
            'body': json.dumps('Comment added successfully')
        }
    except ClientError as e:
        if e.response['Error']['Code'] == 'ConditionalCheckFailedException':
            return {
                'statusCode': 400,
                'body': json.dumps('User has already commented')
            }
        else:
            return {
                'statusCode': 500,
                'body': json.dumps('Internal server error')
            }

def lambda_handler(event, context):
    http_method = event['httpMethod']
    
    if http_method == 'POST':
        return post_comment(event)
    elif http_method == 'GET':
        return get_comments(event)
    else:
        return {
            'statusCode': 405,
            'body': json.dumps('Method not allowed')
        }
