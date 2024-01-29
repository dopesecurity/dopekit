from example_lambda import lambda_handler


def test_handler():
    expected = {"message": "Hello world"}
    actual = lambda_handler({}, {})
    assert expected == actual
