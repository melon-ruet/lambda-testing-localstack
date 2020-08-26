import os
import unittest

import boto3
from localstack.services import infra

from tests import terraform_helper


class AWSLambdaTest(unittest.TestCase):
    localstack_endpoint = 'http://localhost:4566'
    lambda_function_name = 'dynamic-test-lambda-function'

    def set_tf_var(self):
        os.environ["TF_VAR_lambda_function_name"] = self.lambda_function_name

    def setUp(self):
        # Start localstack
        infra.start_infra(apis=['lambda', 'iam', 'cloudwatch'], asynchronous=True)
        self.set_tf_var()
        terraform_helper.terraform_start()

    def test_lambda_response(self):
        client = boto3.client(
            service_name='lambda',
            endpoint_url=self.localstack_endpoint
        )
        response = client.invoke(
            FunctionName=self.lambda_function_name,
            InvocationType='RequestResponse'
        )
        assert response['StatusCode'] == 200
        assert response['Payload']
        html = response['Payload'].read().decode('utf-8')
        # Check if "Example Domain" text exists in example.com
        assert 'Example Domain' in html

    def tearDown(self):
        terraform_helper.destroy_resources()
        # Stop localstack
        infra.stop_infra()


if __name__ == '__main__':
    unittest.main()
