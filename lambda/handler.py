import logging
import urllib.request

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)


def lambda_handler(event, context):
    with urllib.request.urlopen('https://example.com') as response:
        html = response.read().decode('utf-8')
        LOGGER.info(html)
        return html
