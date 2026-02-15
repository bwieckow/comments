# Comments Service

This service allows you to post and retrieve comments using AWS DynamoDB. Below are the instructions to set up and run the service locally.

## Requirements

Make sure you have installed the required dependencies:

```bash
pip install -r requirements.txt
```

## AWS Credentials

Ensure that you have set up your AWS credentials. You can do this by either configuring the AWS CLI with your credentials or setting the following environment variables:

```bash
export AWS_ACCESS_KEY_ID=your_access_key_id
export AWS_SECRET_ACCESS_KEY=your_secret_access_key
export AWS_DEFAULT_REGION=eu-west-1
```

## Environment Variables

Set the required environment variable for the DynamoDB table:

```bash
export DYNAMODB_TABLE_NAME=comments-dev
```

**Note:** The table name should match your DynamoDB table name:
- For development: `comments-dev`
- For production: `comments`

## Running the Script

To run the script from the command line, you can use the following command:

```bash
python src/comment.py
```

Note: The script is designed to be triggered by AWS Lambda, so you may need to simulate an event and context if running locally.

## Example

### POST Request

You can create a test event JSON file (e.g., `src/post_event.json`) with the following content:

```json
{
    "body": "{\"comment_text\": \"This is a great service!\", \"id_token\": \"your_google_id_token\", \"rating\": 5}",
    "requestContext": {
        "http": {
            "method": "POST"
        }
    }
}
```

Then, run the script with the test event:

```bash
python -c 'import json; import src.comment as comment; event = json.load(open("src/post_event.json")); print(comment.lambda_handler(event, None))'
```

Or use the Makefile:

```bash
make test-post
```

### GET Request

You can create a test event JSON file (e.g., `src/get_event.json`) with the following content:

```json
{
    "queryStringParameters": {
        "start_date": "2026-01-01T00:00:00",
        "end_date": "2026-12-31T23:59:59"
    },
    "requestContext": {
        "http": {
            "method": "GET"
        }
    }
}
```

Then, run the script with the test event:

```bash
python -c 'import json; import src.comment as comment; event = json.load(open("src/get_event.json")); print(comment.lambda_handler(event, None))'
```

Or use the Makefile:

```bash
make test-get
```

## Using the Makefile

The Makefile provides convenient commands for setting up and testing the service:

- `make setup` - Creates a virtual environment and installs dependencies
- `make test-post` - Tests the POST endpoint with a sample event
- `make test-get` - Tests the GET endpoint with a sample event
- `make clean` - Removes the virtual environment and Python cache files

To run the service locally, you can use the following commands:

### Example for POST Event

Save the following JSON as `post_event.json`:

```json
{
    "requestContext": {
        "http": {
            "method": "POST"
        }
    },
    "body": "{\"comment_text\": \"This is a test comment.\", \"id_token\": \"test_id_token\", \"rating\": \"5\", \"username\": \"Test User\"}"
}
```

Run the command:

```sh
python -c 'import json; import src.comment as comment; event = json.load(open("post_event.json")); print(comment.lambda_handler(event, None))'
```

### Example for GET Event

Save the following JSON as `get_event.json`:

```json
{
    "requestContext": {
        "http": {
            "method": "GET"
        }
    },
    "queryStringParameters": {
        "start_date": "2023-01-01T00:00:00Z",
        "end_date": "2023-12-31T23:59:59Z"
    }
}
```

Run the command:

```sh
python -c 'import json; import src.comment as comment; event = json.load(open("get_event.json")); print(comment.lambda_handler(event, None))'
```

## Getting an ID Token

To get an `id_token`, you can follow the instructions provided by Google Cloud. Here is an example:

### Method 1: Using Google Cloud SDK

1. Install the Google Cloud SDK:
    ```sh
    curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-367.0.0-linux-x86_64.tar.gz
    tar -xf google-cloud-sdk-367.0.0-linux-x86_64.tar.gz
    ./google-cloud-sdk/install.sh
    ```

2. Initialize the SDK:
    ```sh
    gcloud init
    ```

3. Get an ID token:
    ```sh
    gcloud auth print-identity-token
    ```

### Method 2: Using Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/).
2. Open the Cloud Shell by clicking on the terminal icon in the top right corner.
3. Execute the following command to get an ID token:
    ```sh
    gcloud auth print-identity-token
    ```

For more details, refer to the [Google Cloud documentation](https://cloud.google.com/docs/authentication/get-id-token#generic-dev).

Ensure you have the necessary AWS credentials configured and the DynamoDB table `comments` created in your AWS account.
