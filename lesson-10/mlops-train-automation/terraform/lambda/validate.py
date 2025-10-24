import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.info("Received event: %s", json.dumps(event))
    print("Validating data...")
    data = event.get("data")
    if data is None:
        message = {"status": "failed", "reason": "no data provided"}
        logger.info("Validation result: %s", message)
        return message

    if not isinstance(data, dict):
        message = {"status": "failed", "reason": "data must be an object"}
        logger.info("Validation result: %s", message)
        return message

    message = {"status": "ok", "validated": True}
    logger.info("Validation result: %s", message)
    return message
