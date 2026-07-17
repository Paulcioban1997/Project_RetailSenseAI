import json
import logging
import os
from pathlib import Path

import joblib
os.environ.setdefault("KERAS_BACKEND", "tensorflow")

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
CACHE = {}
FALLBACK_SENTIMENT_MODEL_ID = os.getenv(
    "RETAILSENSE_SENTIMENT_MODEL_ID",
    "nlptown/bert-base-multilingual-uncased-sentiment",
)


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
        from keras.models import load_model

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
        import torch

        return torch.load(path, map_location="cpu")
    except Exception as exc:
        _record_error(key, path, exc)
        return None


def _safe_transformer_tokenizer(key: str, path: Path):
    try:
        from transformers import XLMRobertaTokenizerFast

        local_weights = path / "model.safetensors"
        if local_weights.exists():
            return XLMRobertaTokenizerFast.from_pretrained(path)

        logger.warning(
            "Local sentiment weights are missing at %s. Falling back to remote model %s for tokenizer.",
            local_weights,
            FALLBACK_SENTIMENT_MODEL_ID,
        )
        return XLMRobertaTokenizerFast.from_pretrained(FALLBACK_SENTIMENT_MODEL_ID)
    except Exception as exc:
        try:
            from transformers import AutoTokenizer

            logger.warning(
                "Primary tokenizer load failed for %s. Falling back to AutoTokenizer(%s).",
                path,
                FALLBACK_SENTIMENT_MODEL_ID,
            )
            return AutoTokenizer.from_pretrained(FALLBACK_SENTIMENT_MODEL_ID)
        except Exception as fallback_exc:
            _record_error(key, path, fallback_exc)
            logger.warning("Tokenizer fallback failed after primary error: %s", exc)
            return None


def _safe_transformer_model(key: str, path: Path):
    try:
        from transformers import AutoModelForSequenceClassification

        local_weights = path / "model.safetensors"
        if local_weights.exists():
            return AutoModelForSequenceClassification.from_pretrained(path)

        logger.warning(
            "Local sentiment weights are missing at %s. Falling back to remote model %s.",
            local_weights,
            FALLBACK_SENTIMENT_MODEL_ID,
        )
        return AutoModelForSequenceClassification.from_pretrained(
            FALLBACK_SENTIMENT_MODEL_ID
        )
    except Exception as exc:
        _record_error(key, path, exc)
        return None


LOADERS = {
    "gradient_boosting": lambda: _safe_joblib(
        "gradient_boosting",
        CLASSIFICATION_DIR / "gradient_boosting_optimize_grid.pkl",
    ),
    "quantiles": lambda: _safe_joblib("quantiles", MODELS_DIR / "rfm_quantiles.pkl"),
    "demand_model": lambda: _safe_joblib(
        "demand_model",
        REGRESSION_DIR / "xgboost_regressor_regression_model.pkl",
    ),
    "price_model": lambda: _safe_joblib(
        "price_model",
        REGRESSION_DIR / "xgboost_regression_price.pkl",
    ),
    "weekly_demand_model": lambda: _safe_keras(
        "weekly_demand_model",
        WEEKLY_DEMAND_DIR / "best_rnn_n_items_weekly.keras",
    ),
    "weekly_demand_scaler": lambda: _safe_joblib(
        "weekly_demand_scaler",
        WEEKLY_DEMAND_DIR / "scaler_n_items_weekly.joblib",
    ),
    "weekly_demand_metadata": lambda: _safe_json(
        "weekly_demand_metadata",
        WEEKLY_DEMAND_DIR / "best_weekly_demand_model_metadata.json",
    ) or {},
    "kmeans": lambda: _safe_joblib("kmeans", CLUSTERING_DIR / "kmeans_rfm.pkl"),
    "scaler_rfm": lambda: _safe_joblib("scaler_rfm", CLUSTERING_DIR / "scaler_rfm.pkl"),
    "autoencoder": lambda: _safe_keras(
        "autoencoder",
        AUTOENCODER_DIR / "autoencoder_anomaly_detector.keras",
    ),
    "autoencoder_scaler": lambda: _safe_joblib("autoencoder_scaler", AUTOENCODER_DIR / "scaler.pkl"),
    "autoencoder_threshold": lambda: _safe_joblib(
        "autoencoder_threshold",
        AUTOENCODER_DIR / "threshold.pkl",
    ),
    "autoencoder_features": lambda: _safe_json(
        "autoencoder_features",
        AUTOENCODER_DIR / "features.json",
    ),
    "generator": lambda: _safe_keras("generator", GAN_DIR / "generator.keras"),
    "gan_scaler": lambda: _safe_joblib("gan_scaler", GAN_DIR / "scaler.pkl"),
    "gan_features": lambda: _safe_json("gan_features", GAN_DIR / "features.json"),
    "gnn_state": lambda: _safe_torch("gnn_state", GNN_DIR / "gcn_model.pth"),
    "recommendations": lambda: _safe_json("recommendations", GNN_DIR / "recommendations.json"),
    "tokenizer": lambda: _safe_transformer_tokenizer("tokenizer", TRANSFORMER_DIR),
    "transformer": lambda: _safe_transformer_model("transformer", TRANSFORMER_DIR),
}


class LazyModelRegistry:
    def get(self, key, default=None):
        if key == "__errors__":
            return MODEL_ERRORS

        if key in CACHE:
            return CACHE[key]

        loader = LOADERS.get(key)
        if loader is None:
            return default

        logger.info("Loading RetailSense asset on demand: %s", key)
        value = loader()
        CACHE[key] = value
        return value if value is not None else default


MODELS = LazyModelRegistry()