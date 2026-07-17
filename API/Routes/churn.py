import pandas as pd 
from fastapi import APIRouter
from API.schemas import ReviewClassificationInput
from API.Models.load_models import MODELS

router = APIRouter()


@router.post("/predict/bad-review", summary="Predire si une commande risque d'avoir un mauvais avis")
def predict_churn(data: ReviewClassificationInput):
    """
    Classe une commande selon le risque d'obtenir un `bad_review`.
    """

    model = MODELS["gradient_boosting"]

    status_raw = str(data.order_status).strip().lower().replace("-", "_").replace(" ", "_")
    status_aliases = {
        "not_delivered": "unavailable",
        "notdelivered": "unavailable",
        "cancelled": "canceled",
    }
    order_status = status_aliases.get(status_raw, status_raw)

    X = pd.DataFrame([{

        "order_status": order_status,
        "delay_days": data.delay_days,
        "delivery_days": data.delivery_days,
        "n_items": data.n_items,
        "customer_state": str(data.customer_state).upper(),
        "main_category": str(data.main_category).lower(),
        "purchase_month": data.purchase_month,
        "total_freight": data.total_freight,

    }])

    prediction = model.predict(X)
    pred_value = int(prediction[0])

    # Regle metier: une commande non livree/annulee avec tres grand retard
    # est forcee en risque d'avis negatif.
    if order_status in {"unavailable", "canceled"} and data.delay_days >= 30:
        pred_value = 1

    return {
        "bad_review_prediction": pred_value,
    }


