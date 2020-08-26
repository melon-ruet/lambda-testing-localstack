import logging

import requests

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)


def lambda_handler(event, context):
    response = requests.get("https://example.com")
    LOGGER.info(response.text)
    return response.text
