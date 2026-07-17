from fastapi import APIRouter, HTTPException
import torch

from API.Models.load_models import MODELS
from API.schemas import SentimentInput

router = APIRouter()

# Labels des classes de sentiment
labels = {
    1: "Very Bad",
    2: "Bad",
    3: "Average",
    4: "Good",
    5: "Excellent"
}                    # Dictionnaire associant les scores de sentiment aux étiquettes correspondantes pour une meilleure interprétation des résultats

@router.post("/predict/sentiment", summary="Predire le sentiment d'un avis client")
def predict_sentiment(data: SentimentInput):

    tokenizer = MODELS.get("tokenizer")
    model = MODELS.get("transformer")
    if tokenizer is None or model is None:
        raise HTTPException(
            status_code=503,
            detail={
                "error": "Model unavailable",
                "missing": [k for k in ["tokenizer", "transformer"] if MODELS.get(k) is None],
                "model_errors": MODELS.get("__errors__", {}),
            },
        )

    inputs = tokenizer(
        data.text,
        return_tensors="pt",  # Retourne les tenseurs PyTorch
        truncation=True,   # Troncature du texte si sa longueur dépasse la limite maximale du modèle
        padding=True,  # Ajoute un padding pour que tous les textes aient la même longueur
        max_length=256  # Longueur maximale des séquences
    )

    with torch.no_grad():  # Désactive le calcul des gradients pour économiser de la mémoire et accélérer l'inférence

        outputs = model(**inputs)

        probabilities = torch.softmax(outputs.logits, dim=1)  # Applique la fonction softmax pour obtenir des probabilités

        _, prediction = torch.max(probabilities, dim=1)  # Récupère la classe avec la probabilité la plus élevée

    review_score = int(prediction.item()) + 1  # Les classes sont indexées à partir de 0, donc on ajoute 1 pour obtenir le score réel (1 à 5)

    print("LABEL =", labels[review_score])

    return {

        "review_score": review_score,
        "label": labels[review_score]

    }