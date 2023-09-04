import json
import boto3
import os
import uuid
import logging

dynamodb = boto3.resource('dynamodb')
lambda_client = boto3.client('lambda')

USERS_TABLE = os.environ['USERS_TABLE']
NOTIFY_ADMINS_FUNCTION_NAME = os.environ['NOTIFY_ADMINS_FUNCTION_NAME']

users_table = dynamodb.Table(USERS_TABLE)
logging.basicConfig(level=logging.INFO)

def handler(event, context):
    try:
        body = json.loads(event['body'])
        firstName = body['firstName']
        lastName = body['lastName']
        full_name = f"{firstName} {lastName}"

        insert_user(firstName, lastName)
        invoke_notify_admins(full_name)

        return {
            'statusCode': 200,
            'body': json.dumps('Record inserted successfully!')
        }
    except Exception as e:
        logging.error(f"An error occurred: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps('Internal server error')
        }

def insert_user(firstName, lastName):
    response = users_table.put_item(
        Item={
            'id': str(uuid.uuid4()),
            'firstName': firstName,
            'lastName': lastName
        }
    )
    logging.info(f"Inserted user: {response}")

def invoke_notify_admins(full_name):
    response = lambda_client.invoke(
        FunctionName=NOTIFY_ADMINS_FUNCTION_NAME,
        InvocationType='Event',
        Payload=json.dumps({'fullName': full_name})
    )
    logging.info(f"Invoked Lambda response: {response}")