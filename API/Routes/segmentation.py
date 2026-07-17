from fastapi import APIRouter
from API.schemas import SegmentationInput
from API.Models.load_models import MODELS

import pandas as pd
import numpy as np

router = APIRouter()


SEGMENT_NAMES = {
    0: "Clients occasionnels panier eleve",
    1: "Clients inactifs longue duree",
    2: "Clients actifs recurrents",
    3: "Clients faible valeur",
}

@router.post("/segment/customer", summary="Segmenter un client")
def segment_customer(data: SegmentationInput):
    """
    Segmente un client en fonction de ses caractéristiques RFM.
    """
    # Convertir les données d'entrée en DataFrame
    input_data = pd.DataFrame([{
    "recency": data.recency,
    "frequency": data.frequency,
    "monetary": data.monetary
}])  # On fait sa car on envoi dans le meme ordre les variables que dans le dataframe d'entrainement

    # Aligner l'inference avec l'entrainement KMeans (log1p sur frequency/monetary).
    input_data["frequency"] = np.log1p(input_data["frequency"])
    input_data["monetary"] = np.log1p(input_data["monetary"])

    # Utiliser le modèle KMeans pour prédire le segment du client
    kmeans_model = MODELS["kmeans"]
    scaler_rfm = MODELS["scaler_rfm"]

    # Normaliser les données d'entrée
    input_data_scaled = scaler_rfm.transform(input_data)
    segment = kmeans_model.predict(input_data_scaled)

    segment_id = int(segment[0])

    return {
        "segment": segment_id,
        "segment_name": SEGMENT_NAMES.get(segment_id, f"Segment {segment_id}")
    }
