import os
import boto3
import json

SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']

sns_client = boto3.client('sns')

def format_message(full_name):
    if full_name:
        return f"User {full_name} has been added"
    else:
        return 'A new user has been added'

def handler(event, context):
    full_name = event.get('fullName')

    message = format_message(full_name)    
    sns_client.publish(
        TopicArn=SNS_TOPIC_ARN,
        Message=json.dumps({'default': json.dumps(message)}),
        MessageStructure='json'
    )
