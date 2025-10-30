from fastapi import FastAPI, Request
from pydantic import BaseModel
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from alibi_detect.cd import KSDrift
import numpy as np
import pandas as pd
import joblib
import os
import time
import logging
import requests


logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(message)s")
app = FastAPI()

MODEL_PATH = "../model/model.pkl"
model = joblib.load(MODEL_PATH)
logging.info("Model loaded successfully")
REF_DATA_PATH = "model/reference_data.npy"
if not os.path.exists(REF_DATA_PATH):
    logging.info("No reference data found. Generating new reference_data.npy...")
    ref_data = np.random.normal(0, 1, size=(1000, 3))
    np.save(REF_DATA_PATH, ref_data)
else:
    ref_data = np.load(REF_DATA_PATH)
    logging.info("Reference data loaded")

cd = KSDrift(ref_data, p_val=0.05)
logging.info("Drift detector initialized.")

REQUEST_COUNT = Counter("api_requests_total", "Total number of API requests")
PREDICTION_LATENCY = Histogram("api_latency_seconds", "Prediction latency (seconds)")
DRIFT_ALERT_COUNT = Counter("drift_alerts_total", "Number of detected drifts")

class InputData(BaseModel):
    feature1: float
    feature2: float
    feature3: float


def predict(data: pd.DataFrame):
    preds = model.predict(data)
    return preds.tolist()


def trigger_retrain_pipeline():
    webhook_url = os.getenv("WEBHOOK_URL")
    token = os.getenv("TOKEN")
    try:
        response = requests.post(webhook_url, data={"token": token, "ref": "main"})
        if response.status_code == 201:
            logging.info("Retrain pipeline triggered successfully.")
        else:
            logging.warning(f"Failed to trigger retrain pipeline: {response.text}")
    except Exception as e:
        logging.error(f"Error triggering retrain pipeline: {str(e)}")


@app.post("/predict")
async def make_prediction(request: Request, input_data: InputData):
    REQUEST_COUNT.inc()
    start_time = time.time()
    df = pd.DataFrame([input_data.model_dump()])
    X = df.to_numpy()
    preds = cd.predict(X)
    is_drift = preds["data"]["is_drift"]
    p_val = preds["data"]["p_val"]

    if is_drift:
        DRIFT_ALERT_COUNT.inc()
        logging.warning(f"Drift detected! p_val={p_val}")
        trigger_retrain_pipeline()
        return {"status": "drift_detected", "p_value": p_val.tolist()}

    y_pred = predict(df)
    latency = time.time() - start_time
    PREDICTION_LATENCY.observe(latency)
    logging.info(f"Prediction: {y_pred}| Latency: {latency}")
    return {"status": "ok", "prediction": y_pred, "latency": latency, "p_value": p_val.tolist()}

@app.get("/metrics")
async def metrics():
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}

@app.get("/health")
async def healthcheck():
    return {"status": "healthy"}
