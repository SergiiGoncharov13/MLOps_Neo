import os
import shutil
import itertools
import mlflow
import mlflow.sklearn
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, log_loss
from prometheus_client import CollectorRegistry, Gauge, push_to_gateway


MLFLOW_TRACKING_URI = os.getenv("MLFLOW_TRACKING_URL")
MLFLOW_EXPERIMENT_NAME = "Iris-local-demo"
PUSHGATEWAY_URL = os.getenv("PUSHGATEWAY_URL")
BEST_MODEL_DIR = "best_model"

os.makedirs(BEST_MODEL_DIR, exist_ok=True)
mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)
experiment = mlflow.set_experiment(MLFLOW_EXPERIMENT_NAME)


iris = load_iris()
X_train, X_test, y_train, y_test = train_test_split(
    iris.data, iris.target, test_size=0.2, random_state=42
)

learning_rates = [0.01, 0.1, 1.0]
max_iters = [100, 200]

best_accuracy = 0.0
best_model_path = None

for lr, max_iter in itertools.product(learning_rates, max_iters):
    with mlflow.start_run() as run:
        run_id = run.info.run_id
        params = {"C": lr, "max_iter": max_iter}
        
        model = LogisticRegression(C=lr, max_iter=max_iter, solver="lbfgs", multi_class="auto")
        model.fit(X_train, y_train)
        y_pred = model.predict(X_test)
        y_prob = model.predict_proba(X_test)
        
        acc = accuracy_score(y_test, y_pred)
        loss = log_loss(y_test, y_prob)

        mlflow.log_params(params)
        mlflow.log_metrics({"accuracy": acc, "loss": loss})
        mlflow.sklearn.log_model(model, artifact_path="model")
        
        registry = CollectorRegistry()
        g_acc = Gauge("mlflow_accuracy", "Accuracy of MLflow model", ["run_id"], registry=registry)
        g_loss = Gauge("mlflow_loss", "Log loss of MLflow model", ["run_id"], registry=registry)
        g_acc.labels(run_id=run_id).set(acc)
        g_loss.labels(run_id=run_id).set(loss)
        push_to_gateway(PUSHGATEWAY_URL, job="iris_training", registry=registry)
        
        print(f"Run {run_id} finished: accuracy={acc:.4f}, loss={loss:.4f}")

        if acc > best_accuracy:
            best_accuracy = acc
            best_model_path = f"{BEST_MODEL_DIR}/model_{run_id}"
            if os.path.exists(best_model_path):
                shutil.rmtree(best_model_path)
            mlflow.sklearn.save_model(model, best_model_path)

print(f"\nBest model saved in: {best_model_path} with accuracy={best_accuracy:.4f}")
