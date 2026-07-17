import json
from pathlib import Path
from typing import Callable, Any

import joblib
import numpy as np

ROOT = Path(__file__).resolve().parents[1]


def _enforce_integer_random_state(model: Any) -> Any:
    if not hasattr(model, "get_params") or not hasattr(model, "set_params"):
        return model

    params = model.get_params(deep=True)
    updates = {}
    for key, value in params.items():
        if "random_state" not in key:
            continue
        if value is None:
            continue
        if isinstance(value, (int, np.integer)):
            continue
        updates[key] = 42

    if updates:
        model.set_params(**updates)
    return model


def _best_estimator_or_self(obj: Any) -> Any:
    return getattr(obj, "best_estimator_", obj)


def _identity(obj: Any) -> Any:
    return obj


MODEL_EXPORTS: list[tuple[str, str, Callable[[Any], Any]]] = [
    (
        "Machine-Learning/Models_Classification/gradient_boosting_optimize_grid.pkl",
        "Machine-Learning/Models_Classification/gradient_boosting_model_render.pkl",
        _best_estimator_or_self,
    ),
    (
        "Machine-Learning/Models_Regression/xgboost_regressor_regression_model.pkl",
        "Machine-Learning/Models_Regression/xgboost_regressor_regression_model_render.pkl",
        _identity,
    ),
    (
        "Machine-Learning/Models_Regression/xgboost_regression_price.pkl",
        "Machine-Learning/Models_Regression/xgboost_regression_price_render.pkl",
        _identity,
    ),
    (
        "Machine-Learning/Models_Clustering/kmeans_rfm.pkl",
        "Machine-Learning/Models_Clustering/kmeans_rfm_render.pkl",
        _identity,
    ),
    (
        "Machine-Learning/Models_Clustering/scaler_rfm.pkl",
        "Machine-Learning/Models_Clustering/scaler_rfm_render.pkl",
        _identity,
    ),
    (
        "Deep-Learning/Models_LSTM/scaler_n_items_weekly.joblib",
        "Deep-Learning/Models_LSTM/scaler_n_items_weekly_render.joblib",
        _identity,
    ),
    (
        "Deep-Learning/Models_AutoEncoder/scaler.pkl",
        "Deep-Learning/Models_AutoEncoder/scaler_render.pkl",
        _identity,
    ),
    (
        "Deep-Learning/Models_AutoEncoder/threshold.pkl",
        "Deep-Learning/Models_AutoEncoder/threshold_render.pkl",
        _identity,
    ),
    (
        "Deep-Learning/Models_GAN/scaler.pkl",
        "Deep-Learning/Models_GAN/scaler_render.pkl",
        _identity,
    ),
]


def main() -> None:
    results = []

    for src_rel, dst_rel, transform in MODEL_EXPORTS:
        src = ROOT / src_rel
        dst = ROOT / dst_rel

        if not src.exists():
            results.append(
                {
                    "source": src_rel,
                    "target": dst_rel,
                    "status": "missing_source",
                }
            )
            continue

        try:
            loaded = joblib.load(src)
            transformed = transform(loaded)
            transformed = _enforce_integer_random_state(transformed)
            dst.parent.mkdir(parents=True, exist_ok=True)
            joblib.dump(transformed, dst, compress=3)

            _ = joblib.load(dst)
            results.append(
                {
                    "source": src_rel,
                    "target": dst_rel,
                    "status": "ok",
                    "bytes": dst.stat().st_size,
                    "type": str(type(transformed)),
                }
            )
        except Exception as exc:
            results.append(
                {
                    "source": src_rel,
                    "target": dst_rel,
                    "status": "error",
                    "error": str(exc),
                }
            )

    print(json.dumps({"results": results}, indent=2, ensure_ascii=True))


if __name__ == "__main__":
    main()
