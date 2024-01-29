import json

import boto3
import pytest


def get_tf_output(name: str) -> str:
    with open("../terraform/tf_op.json") as tf_file:
        tf_ops = json.load(tf_file)
        return tf_ops[name]["value"]


@pytest.fixture(scope="session")
def aws_region():
    return get_tf_output("aws_region")


def test_lambda(aws_region):
    lambda_name = get_tf_output("lmb_example_name")
    client = boto3.client("lambda", aws_region)
    response = client.invoke(
        FunctionName=lambda_name,
        InvocationType="RequestResponse",
    )
    response_body = json.loads(response["Payload"].read().decode("utf-8"))

    expected_response = {"message": "Hello world"}
    assert response_body == expected_response
