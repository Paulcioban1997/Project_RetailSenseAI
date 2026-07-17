from fastapi import APIRouter, HTTPException

from API.Models.load_models import MODELS
from API.schemas import RecommendationInput

router = APIRouter()


@router.post("/recommend/products", summary="Recommander des produits similaires")
def recommend_products(data: RecommendationInput):

    recommendations = MODELS.get("recommendations")
    if recommendations is None:
        raise HTTPException(
            status_code=503,
            detail={
                "error": "Model unavailable",
                "missing": ["recommendations"],
                "model_errors": MODELS.get("__errors__", {}),
            },
        )

    product_id = data.product_id

    if product_id not in recommendations:

        return {
            "message": "Produit introuvable."
        }

    return {

        "product_id": product_id,

        "recommended_products":
            recommendations[product_id]

    }