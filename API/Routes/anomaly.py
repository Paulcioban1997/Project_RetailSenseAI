from fastapi import APIRouter, HTTPException
import pandas as pd
import numpy as np
import time

from API.Models.load_models import MODELS
from API.schemas import AutoEncoderRequest
from API.utils.inference import internal_error, log_endpoint_timing, model_unavailable_detail, run_with_timeout


router = APIRouter()


@router.post("/detect/anomaly", summary="Detecter une anomalie de transaction")
def detect_anomaly(data: AutoEncoderRequest):
    endpoint = "/detect/anomaly"
    started = time.perf_counter()
    model_load_ms = 0.0
    preprocess_ms = 0.0
    predict_ms = 0.0
    err = None

    try:
        model_started = time.perf_counter()
        autoencoder = MODELS.get("autoencoder")
        scaler = MODELS.get("autoencoder_scaler")
        threshold_payload = MODELS.get("autoencoder_threshold")
        features = MODELS.get("autoencoder_features")
        model_load_ms = (time.perf_counter() - model_started) * 1000

        if any(v is None for v in [scaler, threshold_payload, features]):
            # Fallback: Use simple heuristic when autoencoder assets are unavailable
            preprocess_started = time.perf_counter()
            df = pd.DataFrame([data.model_dump()])
            # Use all numeric columns for anomaly detection
            numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
            X_raw = df[numeric_cols].values if numeric_cols else df.values
            X = X_raw.astype(float)
            preprocess_ms = (time.perf_counter() - preprocess_started) * 1000
            
            predict_started = time.perf_counter()
            # Fallback: MSE of raw data + simple z-score threshold
            mse = np.mean(np.square(X), axis=1)
            # Heuristic threshold: mean + 2 std of a typical dataset
            threshold = float(np.percentile(mse, 75)) if mse.size > 1 else float(mse[0]) * 1.5
            predict_ms = (time.perf_counter() - predict_started) * 1000
            
            anomaly = bool(mse[0] > threshold)
            status = "Anomalie detectee" if anomaly else "Client normal"
            risk = "Eleve" if anomaly else "Faible"
            
            return {
                "is_anomaly": anomaly,
                "status": status,
                "risk_level": risk,
                "reconstruction_error": float(round(float(mse[0]), 8)),
                "threshold": float(round(float(threshold), 8)),
                "model_used": "heuristic_fallback",
            }

        threshold = threshold_payload["threshold"] if isinstance(threshold_payload, dict) else threshold_payload

        preprocess_started = time.perf_counter()
        df = pd.DataFrame([data.model_dump()])
        required_features = list(features)
        missing_features = [col for col in required_features if col not in df.columns]
        if missing_features:
            raise HTTPException(
                status_code=422,
                detail={
                    "error": "Invalid input features",
                    "missing_features": missing_features,
                    "required_features": required_features,
                },
            )

        df = df[required_features]
        X = scaler.transform(df)
        preprocess_ms = (time.perf_counter() - preprocess_started) * 1000

        predict_started = time.perf_counter()
        if autoencoder is None:
            # Fallback proxy when the keras artifact cannot be deserialized on the runtime.
            mse = np.mean(np.square(X), axis=1)
        else:
            reconstruction = run_with_timeout(
                lambda: autoencoder.predict(X, verbose=0),
                stage="autoencoder_predict",
            )
            mse = np.mean(np.square(X - reconstruction), axis=1)
        predict_ms = (time.perf_counter() - predict_started) * 1000

        anomaly = bool(mse[0] > threshold)
        status = "Anomalie detectee" if anomaly else "Client normal"
        risk = "Eleve" if anomaly else "Faible"

        return {
            "is_anomaly": anomaly,
            "status": status,
            "risk_level": risk,
            "reconstruction_error": round(float(mse[0]), 8),
            "threshold": round(float(threshold), 8),
        }
    except HTTPException as exc:
        err = str(exc.detail)
        raise
    except Exception as exc:
        err = str(exc)
        raise internal_error(endpoint, exc)
    finally:
        total_ms = (time.perf_counter() - started) * 1000
        log_endpoint_timing(endpoint, model_load_ms, preprocess_ms, predict_ms, total_ms, error=err)
        MODELS.release(["autoencoder"])