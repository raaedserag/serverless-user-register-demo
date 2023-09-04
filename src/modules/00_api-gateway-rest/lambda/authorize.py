import os
import jwt
import logging

SECRET_KEY = os.environ['JWT_KEY']

logging.basicConfig(level=logging.INFO)

def handler(event, context):
    try:
        token = event.get('authorizationToken')
        if not token:
            logging.error("No authorization token provided")
            raise Exception("Unauthorized")
        
        method_arn = event['methodArn']
        arn_parts = method_arn.split(':')
        api_gateway_arn_parts = arn_parts[5].split('/')
        method = api_gateway_arn_parts[2]
        resource = api_gateway_arn_parts[3]

        if is_authorized(token, resource, method):
            return generate_allow_policy(method_arn)
        else:
            logging.error("User is not authorized to access this resource")
            raise Exception("Forbidden")
    except Exception as e:
        logging.error(f"An error occurred: {e}")
        raise Exception(e)


def is_authorized(token, resource, method):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])

        access_identifier = f"{resource}:{method}"
        wildcard_access_identifier = f"{resource}:*"

        claims = payload.get("claims", {})
        can_access = claims.get("can_access", [])

        if access_identifier in can_access or wildcard_access_identifier in can_access:
            return True
        else:
            return False
    except jwt.PyJWTError:
        logging.error("Invalid JWT token")
        raise Exception("Unauthorized")

def generate_allow_policy(resource):
    policy_document = {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "execute-api:Invoke",
                "Effect": "Allow",
                "Resource": resource
            }
        ]
    }
    auth_response = {
        "policyDocument": policy_document
    }
    return auth_response
