from fastapi import APIRouter, HTTPException
from API.schemas import DemandInput, PriceInput, WeeklyDemandInput
from API.Models.load_models import MODELS
from API.utils.inference import internal_error, log_endpoint_timing, model_unavailable_detail, run_with_timeout
import time

import pandas as pd
import numpy as np

router = APIRouter()
demand_router = router  # Alias pour la route de prévision de la demande


def _align_weekly_window(history: np.ndarray, expected_timesteps: int) -> np.ndarray:
    if history.size >= expected_timesteps:
        return history[-expected_timesteps:]

    pad_value = float(history[-1]) if history.size > 0 else 0.0
    pad_count = expected_timesteps - history.size
    padded = np.pad(history, (pad_count, 0), mode="constant", constant_values=pad_value)
    return padded.astype(float)


@router.post("/predict/demand", summary="Predire la demande d'une commande")
def predict_demand(data: DemandInput):
    """
    Prédit la demande (n_items) à partir des caractéristiques de commande.
    """

    endpoint = "/predict/demand"
    started = time.perf_counter()
    model_load_ms = 0.0
    preprocess_ms = 0.0
    predict_ms = 0.0
    err = None

    try:
        model_started = time.perf_counter()
        model = MODELS.get("demand_model")
        model_load_ms = (time.perf_counter() - model_started) * 1000
        if model is None:
            missing = ["demand_model"]
            raise HTTPException(
                status_code=503,
                detail=model_unavailable_detail(missing, MODELS.get("__errors__", {})),
            )

        preprocess_started = time.perf_counter()
        input_data = pd.DataFrame([{
            "order_status": data.order_status,
            "customer_state": data.customer_state,
            "delivery_days": data.delivery_days,
            "delay_days": data.delay_days,
            "purchase_month": data.purchase_month,
            "purchase_dow": data.purchase_dow,
            "total_price": data.total_price,
            "total_freight": data.total_freight,
            "total_weight": data.total_weight,
            "main_category": data.main_category,
            "payment_value": data.payment_value,
            "max_installments": data.max_installments,
            "payment_type": data.payment_type,
        }])
        preprocess_ms = (time.perf_counter() - preprocess_started) * 1000

        predict_started = time.perf_counter()
        prediction_log = run_with_timeout(lambda: model.predict(input_data), stage="demand_predict")
        prediction = np.expm1(prediction_log)
        prediction = np.clip(prediction, 0, None)
        predict_ms = (time.perf_counter() - predict_started) * 1000

        return {
            "predicted_n_items": round(float(prediction[0]), 4)
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


@router.post("/predict/weekly-demand", summary="Predire la demande hebdomadaire (7-14 jours)")
def predict_weekly_demand(data: WeeklyDemandInput):
    """
    Prédit la demande hebdomadaire future à partir des dernières semaines.
    """
    endpoint = "/predict/weekly-demand"
    started = time.perf_counter()
    model_load_ms = 0.0
    preprocess_ms = 0.0
    predict_ms = 0.0
    err = None
    extra = None

    try:
        model_started = time.perf_counter()
        model = MODELS.get("weekly_demand_model")
        scaler = MODELS.get("weekly_demand_scaler")
        metadata = MODELS.get("weekly_demand_metadata", {})
        model_load_ms = (time.perf_counter() - model_started) * 1000

        if model is None or scaler is None:
            missing = [k for k in ["weekly_demand_model", "weekly_demand_scaler"] if MODELS.get(k) is None]
            raise HTTPException(
                status_code=503,
                detail=model_unavailable_detail(missing, MODELS.get("__errors__", {})),
            )

        preprocess_started = time.perf_counter()
        look_back = int(metadata.get("look_back", 14))
        history = np.asarray(data.recent_weekly_n_items, dtype=float).reshape(-1)
        if history.size < look_back:
            raise HTTPException(
                status_code=422,
                detail={
                    "error": "Invalid weekly history length",
                    "required_look_back": look_back,
                    "received": int(history.size),
                },
            )

        model_input_shape = getattr(model, "input_shape", (None, look_back, 1))
        if isinstance(model_input_shape, list):
            model_input_shape = model_input_shape[0]
        expected_timesteps = look_back
        expected_features = 1
        if isinstance(model_input_shape, tuple) and len(model_input_shape) >= 3:
            if model_input_shape[1] not in (None, -1):
                expected_timesteps = int(model_input_shape[1])
            if model_input_shape[2] not in (None, -1):
                expected_features = int(model_input_shape[2])

        rolling_window = _align_weekly_window(history, expected_timesteps)
        received_shape = (1, expected_timesteps, 1)
        expected_shape = model_input_shape
        extra = f"received_shape={received_shape}; expected_shape={expected_shape}; horizon_days={data.horizon_days}"
        preprocess_ms = (time.perf_counter() - preprocess_started) * 1000

        predict_started = time.perf_counter()
        horizon_weeks = 1 if data.horizon_days <= 7 else 2
        weekly_forecasts = []
        for _ in range(horizon_weeks):
            window_scaled = scaler.transform(rolling_window.reshape(-1, 1))
            model_input = window_scaled.reshape(1, expected_timesteps, 1)
            if expected_features > 1:
                model_input = np.repeat(model_input, expected_features, axis=2)

            pred_scaled = run_with_timeout(
                lambda: model.predict(model_input, verbose=0),
                stage="weekly_demand_predict",
            )
            pred_scaled = np.asarray(pred_scaled).reshape(-1, 1)
            pred_scaled = np.clip(pred_scaled, 0.0, 1.0)
            pred_value = scaler.inverse_transform(pred_scaled).reshape(-1)[0]
            pred_value = float(np.clip(pred_value, 0, None))

            weekly_forecasts.append(round(pred_value, 2))
            rolling_window = np.append(rolling_window[1:], pred_value)
        predict_ms = (time.perf_counter() - predict_started) * 1000

        response = {
            "horizon_days": data.horizon_days,
            "look_back_used": expected_timesteps,
            "model_used": "best_rnn_n_items_weekly.keras",
            "predicted_week_1_n_items": weekly_forecasts[0],
        }
        if horizon_weeks == 2:
            response["predicted_week_2_n_items"] = weekly_forecasts[1]

        return response
    except HTTPException as exc:
        err = str(exc.detail)
        raise
    except Exception as exc:
        err = str(exc)
        raise internal_error(endpoint, exc)
    finally:
        total_ms = (time.perf_counter() - started) * 1000
        log_endpoint_timing(endpoint, model_load_ms, preprocess_ms, predict_ms, total_ms, error=err, extra=extra)
        MODELS.release(["weekly_demand_model"])


@router.post("/predict/price", summary="Predire le prix d'un produit")
def predict_price(data: PriceInput):
    """
    Prédit le prix d'un produit à partir de ses caractéristiques.
    """

    endpoint = "/predict/price"
    started = time.perf_counter()
    model_load_ms = 0.0
    preprocess_ms = 0.0
    predict_ms = 0.0
    err = None

    try:
        model_started = time.perf_counter()
        model = MODELS.get("price_model")
        model_load_ms = (time.perf_counter() - model_started) * 1000
        if model is None:
            missing = ["price_model"]
            raise HTTPException(
                status_code=503,
                detail=model_unavailable_detail(missing, MODELS.get("__errors__", {})),
            )

        preprocess_started = time.perf_counter()
        input_data = pd.DataFrame([{
            "order_item_id": data.order_item_id,
            "freight_value": data.freight_value,
            "order_status": data.order_status,
            "product_category_name": data.product_category_name,
            "product_name_lenght": data.product_name_lenght,
            "product_description_lenght": data.product_description_lenght,
            "product_photos_qty": data.product_photos_qty,
            "product_weight_g": data.product_weight_g,
            "product_length_cm": data.product_length_cm,
            "product_height_cm": data.product_height_cm,
            "product_width_cm": data.product_width_cm,
        }])
        preprocess_ms = (time.perf_counter() - preprocess_started) * 1000

        predict_started = time.perf_counter()
        prediction_log = run_with_timeout(lambda: model.predict(input_data), stage="price_predict")
        prediction = np.expm1(prediction_log)
        predict_ms = (time.perf_counter() - predict_started) * 1000

        return {
            "predicted_price": round(float(prediction[0]), 2)
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