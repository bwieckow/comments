# Comments Service

This service allows you to post and retrieve comments using AWS DynamoDB. Below are the instructions to set up and run the service locally.

## Prerequisites

- Python 3.7 or higher
- AWS CLI configured with appropriate permissions
- Virtualenv

## Setup

1. Clone the repository:
    ```sh
    git clone <repository-url>
    cd comments
    ```

2. Create a virtual environment:
    ```sh
    python3 -m venv venv
    ```

3. Activate the virtual environment:
    - On macOS/Linux:
        ```sh
        source venv/bin/activate
        ```
    - On Windows:
        ```sh
        .\venv\Scripts\activate
        ```

4. Install the required packages:
    ```sh
    pip install -r requirements.txt
    ```

## Running the Service

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
    "body": "{\"comment_text\": \"This is a test comment.\", \"id_token\": \"test_id_token\", \"rating\": 5}"
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
