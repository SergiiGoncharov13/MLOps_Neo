import joblib
import numpy as np
from sklearn.linear_model import LinearRegression

def retrain_model():
    X = np.random.rand(100, 3)
    y = X @ np.array([2.0, -1.0, 0.5]) + np.random.randn(100) * 0.1
    model = LinearRegression()
    model.fit(X, y)
    joblib.dump(model, "model.pkl")
    print(f"Model trained and saved")


if __name__ == "__main__":
    retrain_model()
