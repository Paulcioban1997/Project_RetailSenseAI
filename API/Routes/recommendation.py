from fastapi import APIRouter

from API.Models.load_models import MODELS
from API.schemas import RecommendationInput

router = APIRouter()


@router.post("/recommend/products", summary="Recommander des produits similaires")
def recommend_products(data: RecommendationInput):

    recommendations = MODELS["recommendations"]

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