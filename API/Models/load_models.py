import json
import logging
import os
from pathlib import Path

import joblib
import torch
os.environ.setdefault("KERAS_BACKEND", "tensorflow")

from keras.models import load_model
from transformers import AutoModelForSequenceClassification, XLMRobertaTokenizerFast

from API.config import (
    AUTOENCODER_DIR,
    CLASSIFICATION_DIR,
    CLUSTERING_DIR,
    DL_DIR,
    GAN_DIR,
    GNN_DIR,
    REGRESSION_DIR,
    TRANSFORMER_DIR,
)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("retailsense.models")

MODELS_DIR = Path(__file__).resolve().parent
WEEKLY_DEMAND_DIR = DL_DIR / "Models_LSTM"
MODEL_ERRORS = {}


def _record_error(key: str, path: Path, exc: Exception) -> None:
    MODEL_ERRORS[key] = {
        "path": str(path),
        "error": str(exc),
    }
    logger.warning("Model asset missing or invalid: %s (%s)", key, path)


def _safe_joblib(key: str, path: Path):
    try:
        return joblib.load(path)
    except Exception as exc:
        _record_error(key, path, exc)
        return None


def _safe_keras(key: str, path: Path):
    try:
        return load_model(path)
    except Exception as exc:
        _record_error(key, path, exc)
        return None


def _safe_json(key: str, path: Path):
    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception as exc:
        _record_error(key, path, exc)
        return None


def _safe_torch(key: str, path: Path):
    try:
        return torch.load(path, map_location="cpu")
    except Exception as exc:
        _record_error(key, path, exc)
        return None


def _safe_transformer_tokenizer(key: str, path: Path):
    try:
        return XLMRobertaTokenizerFast.from_pretrained(path)
    except Exception as exc:
        _record_error(key, path, exc)
        return None


def _safe_transformer_model(key: str, path: Path):
    try:
        return AutoModelForSequenceClassification.from_pretrained(path)
    except Exception as exc:
        _record_error(key, path, exc)
        return None


logger.info("Loading RetailSense model assets...")

gradient_boosting_model = _safe_joblib(
    "gradient_boosting",
    CLASSIFICATION_DIR / "gradient_boosting_optimize_grid.pkl",
)
quantiles = _safe_joblib("quantiles", MODELS_DIR / "rfm_quantiles.pkl")

xgboost_demand_model = _safe_joblib(
    "demand_model",
    REGRESSION_DIR / "xgboost_regressor_regression_model.pkl",
)
xgboost_price_model = _safe_joblib(
    "price_model",
    REGRESSION_DIR / "xgboost_regression_price.pkl",
)

weekly_demand_model = _safe_keras(
    "weekly_demand_model",
    WEEKLY_DEMAND_DIR / "best_rnn_n_items_weekly.keras",
)
weekly_demand_scaler = _safe_joblib(
    "weekly_demand_scaler",
    WEEKLY_DEMAND_DIR / "scaler_n_items_weekly.joblib",
)
weekly_demand_metadata = _safe_json(
    "weekly_demand_metadata",
    WEEKLY_DEMAND_DIR / "best_weekly_demand_model_metadata.json",
) or {}

kmeans_rfm = _safe_joblib("kmeans", CLUSTERING_DIR / "kmeans_rfm.pkl")
scaler_rfm = _safe_joblib("scaler_rfm", CLUSTERING_DIR / "scaler_rfm.pkl")

autoencoder_model = _safe_keras(
    "autoencoder",
    AUTOENCODER_DIR / "autoencoder_anomaly_detector.keras",
)
autoencoder_scaler = _safe_joblib("autoencoder_scaler", AUTOENCODER_DIR / "scaler.pkl")
autoencoder_threshold = _safe_joblib(
    "autoencoder_threshold",
    AUTOENCODER_DIR / "threshold.pkl",
)
autoencoder_features = _safe_json("autoencoder_features", AUTOENCODER_DIR / "features.json")

generator_model = _safe_keras("generator", GAN_DIR / "generator.keras")
gan_scaler = _safe_joblib("gan_scaler", GAN_DIR / "scaler.pkl")
gan_features = _safe_json("gan_features", GAN_DIR / "features.json")

gnn_model_state = _safe_torch("gnn_state", GNN_DIR / "gcn_model.pth")
recommendations = _safe_json("recommendations", GNN_DIR / "recommendations.json")

tokenizer = _safe_transformer_tokenizer("tokenizer", TRANSFORMER_DIR)
transformer_model = _safe_transformer_model("transformer", TRANSFORMER_DIR)

MODELS = {
    "gradient_boosting": gradient_boosting_model,
    "quantiles": quantiles,
    "demand_model": xgboost_demand_model,
    "price_model": xgboost_price_model,
    "weekly_demand_model": weekly_demand_model,
    "weekly_demand_scaler": weekly_demand_scaler,
    "weekly_demand_metadata": weekly_demand_metadata,
    "kmeans": kmeans_rfm,
    "scaler_rfm": scaler_rfm,
    "autoencoder": autoencoder_model,
    "autoencoder_scaler": autoencoder_scaler,
    "autoencoder_threshold": autoencoder_threshold,
    "autoencoder_features": autoencoder_features,
    "generator": generator_model,
    "gan_scaler": gan_scaler,
    "gan_features": gan_features,
    "gnn_state": gnn_model_state,
    "recommendations": recommendations,
    "transformer": transformer_model,
    "tokenizer": tokenizer,
    "__errors__": MODEL_ERRORS,
}

if MODEL_ERRORS:
    logger.warning("Loaded with missing assets: %s", list(MODEL_ERRORS.keys()))
else:
    logger.info("All RetailSense model assets loaded successfully.")