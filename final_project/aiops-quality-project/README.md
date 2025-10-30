# AIOps quality monitoring

## Feature description
| Feature                | Description                                                 |
| ---------------------- | ----------------------------------------------------------- |
| **FastAPI**            | Runs model inference service                                |
| **Model Loading**      | Loads `model.pkl` from `/model`                             |
| **Prediction Logic**   | `predict()` function for predictions                        |
| **Great Expectations** | Simple column-based drift/quality validation                |
| **Logging**            | All requests and results go to stdout (for Loki)            |
| **Prometheus Metrics** | `/metrics` exposes latency, request, drift counters         |
| **Drift Trigger**      | If validation fails, logs drift and triggers GitLab retrain |
| **ArgoCD Ready**       | Stateless, easily containerized for Helm deployment         |

## Local test
Required Python version 3.9 - 3.13.0 for alibi-detect <br>

Install
```bash
pip install -r requirements.txt
```

```bash
cd aiops-quality-project/app
uvicorn main:app --reload
```
Test with curl
```bash
curl -X POST "http://localhost:8000/predict" \
     -H "Content-Type: application/json" \
     -d '{"feature1": 0.5, "feature2": 1.2, "feature3": -0.3}'
```
Or open http://localhost:8000/docs


## Check logging
```bash
kubectl logs -l app=aiops-quality-service -f
```
Grafana <br>
Open Grafana at http://localhost:3000 <br>
Default login/password: admin/admin

## Check drift detection
Send data with significantly different feature values:
```bash
curl -X POST "http://localhost:8000/predict" \
     -H "Content-Type: application/json" \
     -d '{"feature1": 10.0, "feature2": 12.0, "feature3": 15.0}'
```
When drift is detected, a webhook triggers the retraining job in GitLab CI