from fastapi import APIRouter, HTTPException
from API.schemas import DemandInput, PriceInput, WeeklyDemandInput
from API.Models.load_models import MODELS

import pandas as pd
import numpy as np

router = APIRouter()
demand_router = router  # Alias pour la route de prévision de la demande


@router.post("/predict/demand", summary="Predire la demande d'une commande")
def predict_demand(data: DemandInput):
    """
    Prédit la demande (n_items) à partir des caractéristiques de commande.
    """

    # Conversion des données d'entrée en DataFrame
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

    # Charger le meilleur pipeline de prévision de la demande
    model = MODELS.get("demand_model")
    if model is None:
        raise HTTPException(
            status_code=503,
            detail={
                "error": "Model unavailable",
                "missing": ["demand_model"],
                "model_errors": MODELS.get("__errors__", {}),
            },
        )

    prediction_log = model.predict(input_data)
    prediction = np.expm1(prediction_log)
    prediction = np.clip(prediction, 0, None)

    return {
        "predicted_n_items": round(float(prediction[0]), 4)
    }


@router.post("/predict/weekly-demand", summary="Predire la demande hebdomadaire (7-14 jours)")
def predict_weekly_demand(data: WeeklyDemandInput):
    """
    Prédit la demande hebdomadaire future à partir des dernières semaines.
    """
    model = MODELS.get("weekly_demand_model")
    scaler = MODELS.get("weekly_demand_scaler")
    if model is None or scaler is None:
        raise HTTPException(
            status_code=503,
            detail={
                "error": "Model unavailable",
                "missing": [k for k in ["weekly_demand_model", "weekly_demand_scaler"] if MODELS.get(k) is None],
                "model_errors": MODELS.get("__errors__", {}),
            },
        )
    metadata = MODELS.get("weekly_demand_metadata", {})

    look_back = int(metadata.get("look_back", 14))
    history = np.array(data.recent_weekly_n_items, dtype=float)

    if history.size < look_back:
        return {
            "error": f"Il faut au minimum {look_back} valeurs hebdomadaires.",
            "required_look_back": look_back,
            "received": int(history.size),
        }

    horizon_weeks = 1 if data.horizon_days <= 7 else 2
    rolling_window = history[-look_back:].copy()

    weekly_forecasts = []
    for _ in range(horizon_weeks):
        window_scaled = scaler.transform(rolling_window.reshape(-1, 1))
        model_input = window_scaled.reshape(1, look_back, 1)

        pred_scaled = model.predict(model_input, verbose=0)
        pred_scaled = np.clip(pred_scaled, 0.0, 1.0)
        pred_value = scaler.inverse_transform(pred_scaled).reshape(-1)[0]
        pred_value = float(np.clip(pred_value, 0, None))

        weekly_forecasts.append(round(pred_value, 2))
        rolling_window = np.append(rolling_window[1:], pred_value)

    response = {
        "horizon_days": data.horizon_days,
        "look_back_used": look_back,
        "model_used": "best_rnn_n_items_weekly.keras",
        "predicted_week_1_n_items": weekly_forecasts[0],
    }
    if horizon_weeks == 2:
        response["predicted_week_2_n_items"] = weekly_forecasts[1]

    return response


@router.post("/predict/price", summary="Predire le prix d'un produit")
def predict_price(data: PriceInput):
    """
    Prédit le prix d'un produit à partir de ses caractéristiques.
    """

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

    model = MODELS.get("price_model")
    if model is None:
        raise HTTPException(
            status_code=503,
            detail={
                "error": "Model unavailable",
                "missing": ["price_model"],
                "model_errors": MODELS.get("__errors__", {}),
            },
        )

    prediction_log = model.predict(input_data)
    prediction = np.expm1(prediction_log)

    return {
        "predicted_price": round(float(prediction[0]), 2)
    }