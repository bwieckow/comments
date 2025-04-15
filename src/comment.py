import json
import boto3
import base64
import urllib.request  # Import urllib.request
from botocore.exceptions import ClientError
from datetime import datetime, timezone  # Import timezone

dynamodb = boto3.resource('dynamodb', region_name='eu-west-1')
table = dynamodb.Table('comments')

def validate_input(event, required_fields):
    for field in required_fields:
        if field not in event:
            return False, f"Missing required field: {field}"
    return True, None

def get_comments(event):
    query_parameters = event['queryStringParameters']
    is_valid, error_message = validate_input(query_parameters, ['start_date', 'end_date'])
    if not is_valid:
        return {
            'statusCode': 400,
            'body': json.dumps(error_message)
        }

    start_date = query_parameters['start_date']
    end_date = query_parameters['end_date']
    
    try:
        response = table.scan(
            FilterExpression="comment_date BETWEEN :start_date AND :end_date",
            ExpressionAttributeValues={
                ":start_date": start_date,
                ":end_date": end_date
            }
        )
        print("Response from DynamoDB:", response)  # Debugging line
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
    body = event.get("body", "")
    is_base64 = event.get("isBase64Encoded", False)

    if is_base64:
        try:
            decoded_body = base64.b64decode(body).decode("utf-8")
            print("Decoded Body:", decoded_body)
        except Exception as e:
            print("Error decoding body:", str(e))
            return {
                'statusCode': 400,
                'body': json.dumps('Invalid base64-encoded body')
            }
    else:
        decoded_body = body
        print("Plain Body:", decoded_body)

    try:
        decoded_body = json.loads(decoded_body)  # Parse the decoded body as JSON
    except json.JSONDecodeError as e:
        print("Error parsing JSON body:", str(e))
        return {
            'statusCode': 400,
            'body': json.dumps('Invalid JSON body')
        }

    is_valid, error_message = validate_input(decoded_body, ['comment_text', 'id_token', 'rating', 'username'])
    if not is_valid:
        return {
            'statusCode': 400,
            'body': json.dumps(error_message)
        }

    id_token = decoded_body['id_token']
    url = f'https://oauth2.googleapis.com/tokeninfo?id_token={id_token}'
    try:
        with urllib.request.urlopen(url) as response:
            if response.status != 200:
                return {
                    'statusCode': 401,
                    'body': json.dumps('Invalid id_token')
                }
            user_info = json.loads(response.read())
            user_id = user_info.get('sub')
            if not user_id:
                return {
                    'statusCode': 400,
                    'body': json.dumps('Missing user_id in token details response')
                }
    except urllib.error.URLError:
        return {
            'statusCode': 401,
            'body': json.dumps('Invalid id_token')
        }

    rating = decoded_body['rating']
    user_name = decoded_body['username']
    comment_text = decoded_body['comment_text']
    comment_date = datetime.now(timezone.utc).isoformat()

    try:
        response = table.put_item(
            Item={
                'user_id': user_id,
                'user_name': user_name,
                'comment_date': comment_date,
                'comment_text': comment_text,
                'rating': rating
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
    http_method = event['requestContext']['http']['method']
    
    if http_method == 'POST':
        return post_comment(event)
    elif http_method == 'GET':
        return get_comments(event)
    else:
        return {
            'statusCode': 405,
            'body': json.dumps('Method not allowed')
        }
