import structlog

logger = structlog.get_logger()
structlog.configure(
    processors=[
        structlog.stdlib.add_log_level,
        structlog.processors.format_exc_info,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.JSONRenderer(),
    ]
)


def lambda_handler(event, context):
    logger.info("Saying hello")
    return {"message": "Hello world"}
