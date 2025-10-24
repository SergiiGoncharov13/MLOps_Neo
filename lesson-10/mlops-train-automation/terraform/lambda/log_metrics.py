import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.info("Received event: %s", json.dumps(event))
    print("Logging metrics...")
    metrics = event.get("metrics", {"dummy_metric": 1})
    logger.info("Metrics: %s", json.dumps(metrics))
    return {"status": "logged", "metrics_count": len(metrics)}
