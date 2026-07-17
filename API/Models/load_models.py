import json
import logging
import os
import platform
import time
import gc
import threading
from pathlib import Path
from typing import Any

import importlib
import importlib.metadata

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
MODEL_LOAD_STATS = {}
CACHE_LOCK = threading.RLock()
KERAS_MODEL_KEYS = {"weekly_demand_model", "autoencoder", "generator"}
TORCH_MODEL_KEYS = {"transformer", "tokenizer", "gnn_state"}
FALLBACK_SENTIMENT_MODEL_ID = os.getenv(
    "RETAILSENSE_SENTIMENT_MODEL_ID",
    "xlm-roberta-base",
)
DISABLE_TRANSFORMER = os.getenv("RETAILSENSE_DISABLE_TRANSFORMER", "1") == "1"

ENDPOINT_MODEL_KEYS = {
    "bad_review": ["gradient_boosting"],
    "demand": ["demand_model"],
    "weekly_demand": ["weekly_demand_model", "weekly_demand_scaler", "weekly_demand_metadata"],
    "price": ["price_model"],
    "segmentation": ["kmeans", "scaler_rfm"],
    "anomaly": ["autoencoder", "autoencoder_scaler", "autoencoder_threshold", "autoencoder_features"],
    "generation": ["generator", "gan_scaler", "gan_features"],
    "recommendation": ["recommendations"],
    "sentiment": ["tokenizer", "transformer"],
}


def _module_version(name: str) -> str:
    try:
        return importlib.metadata.version(name)
    except Exception:
        return "unavailable"


def runtime_versions() -> dict[str, str]:
    return {
        "python": platform.python_version(),
        "numpy": _module_version("numpy"),
        "scipy": _module_version("scipy"),
        "scikit_learn": _module_version("sklearn"),
        "pandas": _module_version("pandas"),
        "xgboost": _module_version("xgboost"),
        "joblib": _module_version("joblib"),
    }


def _candidate_paths(path: Path) -> list[Path]:
    text = str(path)
    candidates = [path]

    if text.startswith("/opt/render/project/src"):
        candidates.append(Path(text.replace("/opt/render/project/src", "/app", 1)))
    if text.startswith("/app"):
        candidates.append(Path(text.replace("/app", "/opt/render/project/src", 1)))

    seen = set()
    ordered = []
    for candidate in candidates:
        key = str(candidate)
        if key in seen:
            continue
        seen.add(key)
        ordered.append(candidate)
    return ordered


def _resolve_asset_path(path: Path) -> Path:
    for candidate in _candidate_paths(path):
        if candidate.exists():
            if candidate != path:
                logger.warning("Resolved asset path fallback: %s -> %s", path, candidate)
            return candidate
    return path


def _safe_joblib_any(key: str, paths: list[Path]):
    last_error = None
    for path in paths:
        value = _safe_joblib(key, path)
        if value is not None:
            return value
        last_error = MODEL_ERRORS.get(key)

    if last_error is not None:
        MODEL_ERRORS[key] = last_error
    return None


def _record_error(key: str, path: Path, exc: Exception) -> None:
    MODEL_ERRORS[key] = {
        "path": str(path),
        "error": str(exc),
    }
    logger.warning("Model asset missing or invalid: %s (%s)", key, path)


def _safe_joblib(key: str, path: Path):
    resolved = _resolve_asset_path(path)
    try:
        return joblib.load(resolved)
    except Exception as exc:
        _record_error(key, resolved, exc)
        return None


def _safe_keras(key: str, path: Path):
    resolved = _resolve_asset_path(path)
    try:
        from keras.models import load_model

        return load_model(resolved, compile=False)
    except Exception as exc:
        primary_error = exc
        try:
            from tensorflow.keras.models import load_model as tf_load_model

            try:
                return tf_load_model(resolved, compile=False, safe_mode=False)
            except TypeError:
                return tf_load_model(resolved, compile=False)
        except Exception as fallback_exc:
            _record_error(key, resolved, fallback_exc)
            logger.warning("Keras fallback load failed after primary error for %s: %s", key, primary_error)
            return None


def _safe_json(key: str, path: Path):
    resolved = _resolve_asset_path(path)
    try:
        with open(resolved, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception as exc:
        _record_error(key, resolved, exc)
        return None


def _safe_torch(key: str, path: Path):
    resolved = _resolve_asset_path(path)
    try:
        import torch

        return torch.load(resolved, map_location="cpu")
    except Exception as exc:
        _record_error(key, resolved, exc)
        return None


def _safe_transformer_tokenizer(key: str, path: Path):
    if DISABLE_TRANSFORMER:
        logger.warning("Transformer loading disabled by RETAILSENSE_DISABLE_TRANSFORMER=1")
        return None

    resolved = _resolve_asset_path(path)
    try:
        os.environ.setdefault("TOKENIZERS_PARALLELISM", "false")
        from transformers import XLMRobertaTokenizerFast

        local_weights = resolved / "model.safetensors"
        if local_weights.exists():
            return XLMRobertaTokenizerFast.from_pretrained(resolved)

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
            _record_error(key, resolved, fallback_exc)
            logger.warning("Tokenizer fallback failed after primary error: %s", exc)
            return None


def _safe_transformer_model(key: str, path: Path):
    if DISABLE_TRANSFORMER:
        logger.warning("Transformer loading disabled by RETAILSENSE_DISABLE_TRANSFORMER=1")
        return None

    resolved = _resolve_asset_path(path)
    try:
        os.environ.setdefault("TOKENIZERS_PARALLELISM", "false")
        os.environ.setdefault("OMP_NUM_THREADS", "1")
        from transformers import AutoModelForSequenceClassification
        import torch

        torch.set_num_threads(1)

        local_weights = resolved / "model.safetensors"
        if local_weights.exists():
            model = AutoModelForSequenceClassification.from_pretrained(
                resolved,
                low_cpu_mem_usage=True,
            )
            model.eval()
            return model

        logger.warning(
            "Local sentiment weights are missing at %s. Falling back to remote model %s.",
            local_weights,
            FALLBACK_SENTIMENT_MODEL_ID,
        )
        model = AutoModelForSequenceClassification.from_pretrained(
            FALLBACK_SENTIMENT_MODEL_ID,
            low_cpu_mem_usage=True,
        )
        model.eval()
        return model
    except Exception as exc:
        _record_error(key, resolved, exc)
        return None


def _release_framework_memory(released_keys: set[str]) -> None:
    if released_keys & KERAS_MODEL_KEYS:
        try:
            from keras import backend as K

            K.clear_session()
        except Exception:
            pass

    if released_keys & TORCH_MODEL_KEYS:
        try:
            import torch

            if torch.cuda.is_available():
                torch.cuda.empty_cache()
        except Exception:
            pass

    gc.collect()


MODEL_PATHS = {
    "gradient_boosting": [
        CLASSIFICATION_DIR / "gradient_boosting_model_render.pkl",
        CLASSIFICATION_DIR / "gradient_boosting_model.pkl",
        CLASSIFICATION_DIR / "gradient_boosting_optimize_grid.pkl",
    ],
    "quantiles": [MODELS_DIR / "rfm_quantiles.pkl"],
    "demand_model": [
        REGRESSION_DIR / "xgboost_regressor_regression_model_render.pkl",
        REGRESSION_DIR / "xgboost_regressor_regression_model.pkl",
    ],
    "price_model": [
        REGRESSION_DIR / "xgboost_regression_price_render.pkl",
        REGRESSION_DIR / "xgboost_regression_price.pkl",
    ],
    "weekly_demand_model": [WEEKLY_DEMAND_DIR / "best_rnn_n_items_weekly.keras"],
    "weekly_demand_scaler": [
        WEEKLY_DEMAND_DIR / "scaler_n_items_weekly_render.joblib",
        WEEKLY_DEMAND_DIR / "scaler_n_items_weekly.joblib",
    ],
    "weekly_demand_metadata": [WEEKLY_DEMAND_DIR / "best_weekly_demand_model_metadata.json"],
    "kmeans": [
        CLUSTERING_DIR / "kmeans_rfm_render.pkl",
        CLUSTERING_DIR / "kmeans_rfm.pkl",
    ],
    "scaler_rfm": [
        CLUSTERING_DIR / "scaler_rfm_render.pkl",
        CLUSTERING_DIR / "scaler_rfm.pkl",
    ],
    "autoencoder": [AUTOENCODER_DIR / "autoencoder_anomaly_detector.keras"],
    "autoencoder_scaler": [
        AUTOENCODER_DIR / "scaler_render.pkl",
        AUTOENCODER_DIR / "scaler.pkl",
    ],
    "autoencoder_threshold": [
        AUTOENCODER_DIR / "threshold_render.pkl",
        AUTOENCODER_DIR / "threshold.pkl",
    ],
    "autoencoder_features": [AUTOENCODER_DIR / "features.json"],
    "generator": [GAN_DIR / "generator.keras"],
    "gan_scaler": [
        GAN_DIR / "scaler_render.pkl",
        GAN_DIR / "scaler.pkl",
    ],
    "gan_features": [GAN_DIR / "features.json"],
    "gnn_state": [GNN_DIR / "gcn_model.pth"],
    "recommendations": [GNN_DIR / "recommendations.json"],
    "tokenizer": [TRANSFORMER_DIR],
    "transformer": [TRANSFORMER_DIR],
}


LOADERS = {
    "gradient_boosting": lambda: _safe_joblib_any(
        "gradient_boosting",
        MODEL_PATHS["gradient_boosting"],
    ),
    "quantiles": lambda: _safe_joblib_any("quantiles", MODEL_PATHS["quantiles"]),
    "demand_model": lambda: _safe_joblib_any("demand_model", MODEL_PATHS["demand_model"]),
    "price_model": lambda: _safe_joblib_any("price_model", MODEL_PATHS["price_model"]),
    "weekly_demand_model": lambda: _safe_keras(
        "weekly_demand_model",
        MODEL_PATHS["weekly_demand_model"][0],
    ),
    "weekly_demand_scaler": lambda: _safe_joblib_any("weekly_demand_scaler", MODEL_PATHS["weekly_demand_scaler"]),
    "weekly_demand_metadata": lambda: _safe_json(
        "weekly_demand_metadata",
        MODEL_PATHS["weekly_demand_metadata"][0],
    ) or {},
    "kmeans": lambda: _safe_joblib_any("kmeans", MODEL_PATHS["kmeans"]),
    "scaler_rfm": lambda: _safe_joblib_any("scaler_rfm", MODEL_PATHS["scaler_rfm"]),
    "autoencoder": lambda: _safe_keras(
        "autoencoder",
        MODEL_PATHS["autoencoder"][0],
    ),
    "autoencoder_scaler": lambda: _safe_joblib_any("autoencoder_scaler", MODEL_PATHS["autoencoder_scaler"]),
    "autoencoder_threshold": lambda: _safe_joblib_any("autoencoder_threshold", MODEL_PATHS["autoencoder_threshold"]),
    "autoencoder_features": lambda: _safe_json(
        "autoencoder_features",
        MODEL_PATHS["autoencoder_features"][0],
    ),
    "generator": lambda: _safe_keras("generator", MODEL_PATHS["generator"][0]),
    "gan_scaler": lambda: _safe_joblib_any("gan_scaler", MODEL_PATHS["gan_scaler"]),
    "gan_features": lambda: _safe_json("gan_features", MODEL_PATHS["gan_features"][0]),
    "gnn_state": lambda: _safe_torch("gnn_state", MODEL_PATHS["gnn_state"][0]),
    "recommendations": lambda: _safe_json("recommendations", MODEL_PATHS["recommendations"][0]),
    "tokenizer": lambda: _safe_transformer_tokenizer("tokenizer", MODEL_PATHS["tokenizer"][0]),
    "transformer": lambda: _safe_transformer_model("transformer", MODEL_PATHS["transformer"][0]),
}


class LazyModelRegistry:
    def get(self, key, default=None):
        if key == "__errors__":
            return MODEL_ERRORS

        if key == "__load_stats__":
            return MODEL_LOAD_STATS

        with CACHE_LOCK:
            if key in CACHE:
                return CACHE[key]

        loader = LOADERS.get(key)
        if loader is None:
            return default

        logger.info("Loading RetailSense asset on demand: %s", key)
        started = time.perf_counter()
        value = loader()
        elapsed_ms = round((time.perf_counter() - started) * 1000, 2)

        MODEL_LOAD_STATS[key] = {
            "loaded": value is not None,
            "duration_ms": elapsed_ms,
            "error": MODEL_ERRORS.get(key),
        }

        if value is None:
            logger.warning("Asset load failed: %s (%.2f ms)", key, elapsed_ms)
        else:
            logger.info("Asset loaded: %s (%.2f ms)", key, elapsed_ms)

        with CACHE_LOCK:
            CACHE[key] = value
        return value if value is not None else default

    def release(self, keys: list[str] | None = None) -> dict[str, Any]:
        with CACHE_LOCK:
            if keys is None:
                target_keys = list(CACHE.keys())
            else:
                target_keys = [k for k in keys if k in CACHE]

            if not target_keys:
                return {"released": [], "remaining": list(CACHE.keys())}

            released = []
            for key in target_keys:
                CACHE.pop(key, None)
                released.append(key)

        _release_framework_memory(set(released))
        logger.info("Released cached assets to reduce memory: %s", released)
        with CACHE_LOCK:
            return {"released": released, "remaining": list(CACHE.keys())}


MODELS = LazyModelRegistry()


def model_file_inventory() -> dict[str, list[dict[str, Any]]]:
    inventory: dict[str, list[dict[str, Any]]] = {}
    for key, paths in MODEL_PATHS.items():
        entries: list[dict[str, Any]] = []
        for path in paths:
            resolved = _resolve_asset_path(path)
            entries.append(
                {
                    "configured_path": str(path),
                    "resolved_path": str(resolved),
                    "exists": resolved.exists(),
                }
            )
        inventory[key] = entries
    return inventory


def startup_diagnostics(preload_models: bool = True) -> dict[str, Any]:
    report: dict[str, Any] = {
        "versions": runtime_versions(),
        "inventory": model_file_inventory(),
        "load": {},
        "errors": {},
    }

    if preload_models:
        for key in LOADERS:
            value = MODELS.get(key)
            report["load"][key] = value is not None
        report["errors"] = dict(MODEL_ERRORS)
        report["load_stats"] = dict(MODEL_LOAD_STATS)

    return report


def endpoint_model_status() -> dict[str, dict[str, bool]]:
    def _key_ready_without_loading(key: str) -> bool:
        with CACHE_LOCK:
            if key in CACHE and CACHE[key] is not None:
                return True

        if key in MODEL_ERRORS:
            return False

        paths = MODEL_PATHS.get(key, [])
        for path in paths:
            if _resolve_asset_path(path).exists():
                return True
        return False

    status: dict[str, dict[str, bool]] = {}
    for endpoint, keys in ENDPOINT_MODEL_KEYS.items():
        status[endpoint] = {key: _key_ready_without_loading(key) for key in keys}
    return status


def get_model_load_stats() -> dict[str, Any]:
    return dict(MODEL_LOAD_STATS)