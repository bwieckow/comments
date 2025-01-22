import json
import boto3
from botocore.exceptions import ClientError

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('comments')

def validate_input(event):
    required_fields = ['comment_id', 'user_id', 'comment_text']
    for field in required_fields:
        if field not in event:
            return False, f"Missing required field: {field}"
    return True, None

def lambda_handler(event, context):
    is_valid, error_message = validate_input(event)
    if not is_valid:
        return {
            'statusCode': 400,
            'body': json.dumps(error_message)
        }

    comment_id = event['comment_id']
    user_id = event['user_id']
    comment_text = event['comment_text']
    
    try:
        response = table.put_item(
            Item={
                'comment_id': comment_id,
                'user_id': user_id,
                'comment_text': comment_text
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
