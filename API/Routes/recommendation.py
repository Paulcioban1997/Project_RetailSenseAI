from fastapi import APIRouter, HTTPException
import time

from API.Models.load_models import MODELS
from API.schemas import RecommendationInput
from API.utils.inference import internal_error, log_endpoint_timing

router = APIRouter()


@router.post("/recommend/products", summary="Recommander des produits similaires")
def recommend_products(data: RecommendationInput):
    endpoint = "/recommend/products"
    started = time.perf_counter()
    model_load_ms = 0.0
    preprocess_ms = 0.0
    predict_ms = 0.0
    err = None

    try:
        model_started = time.perf_counter()
        gnn_state = MODELS.get("gnn_state")
        recommendations = MODELS.get("recommendations")
        model_load_ms = (time.perf_counter() - model_started) * 1000

        missing = []
        if gnn_state is None:
            missing.append("gnn_state")
        if recommendations is None:
            missing.append("recommendations")
        if missing:
            raise HTTPException(
                status_code=503,
                detail={
                    "error": "Model unavailable",
                    "missing": missing,
                    "model_errors": MODELS.get("__errors__", {}),
                },
            )

        preprocess_started = time.perf_counter()
        product_id = str(data.product_id).strip()
        if not product_id:
            raise HTTPException(status_code=422, detail={"error": "product_id is required"})
        preprocess_ms = (time.perf_counter() - preprocess_started) * 1000

        predict_started = time.perf_counter()
        if product_id not in recommendations:
            result = {
                "message": "Produit introuvable."
            }
        else:
            result = {
                "product_id": product_id,
                "recommended_products": recommendations[product_id],
            }
        predict_ms = (time.perf_counter() - predict_started) * 1000

        return result
    except HTTPException as exc:
        err = str(exc.detail)
        raise
    except Exception as exc:
        err = str(exc)
        raise internal_error(endpoint, exc)
    finally:
        total_ms = (time.perf_counter() - started) * 1000
        log_endpoint_timing(endpoint, model_load_ms, preprocess_ms, predict_ms, total_ms, error=err)