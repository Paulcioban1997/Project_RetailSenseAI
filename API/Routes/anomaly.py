from fastapi import APIRouter, HTTPException
import pandas as pd
import numpy as np

from API.Models.load_models import MODELS
from API.schemas import AutoEncoderRequest


router = APIRouter()


@router.post("/detect/anomaly", summary="Detecter une anomalie de transaction")
def detect_anomaly(data: AutoEncoderRequest):

    
    # Chargement des ressources

    autoencoder = MODELS.get("autoencoder")
    scaler = MODELS.get("autoencoder_scaler")
    threshold_payload = MODELS.get("autoencoder_threshold")
    features = MODELS.get("autoencoder_features")
    if any(v is None for v in [autoencoder, scaler, threshold_payload, features]):
        raise HTTPException(
            status_code=503,
            detail={
                "error": "Model unavailable",
                "missing": [
                    k
                    for k in [
                        "autoencoder",
                        "autoencoder_scaler",
                        "autoencoder_threshold",
                        "autoencoder_features",
                    ]
                    if MODELS.get(k) is None
                ],
                "model_errors": MODELS.get("__errors__", {}),
            },
        )
    threshold = threshold_payload["threshold"] if isinstance(threshold_payload, dict) else threshold_payload

    
    # JSON -> DataFrame
    

    df = pd.DataFrame([data.model_dump()])   # Conversion des données JSON reçues en DataFrame pandas pour faciliter le traitement et l'analyse des données

    
    # Colonnes utilisées
    

    df = df[features]    # On sélectionne uniquement les colonnes correspondant aux features utilisées par l'autoencodeur pour la détection d'anomalies

    
    # Normalisation
    

    X = scaler.transform(df)       # Normalisation des données en utilisant le scaler chargé pour obtenir les données normalisées (X)

    
    # Reconstruction
    

    reconstruction = autoencoder.predict(
        X,
        verbose=0
    )                    # Utilisation de l'autoencodeur pour reconstruire les données normalisées (X) et obtenir les données reconstruites (reconstruction)

    
    # Erreur de reconstruction
    

    mse = np.mean(
        np.square(X - reconstruction),
        axis=1
    )          # Calcul de l'erreur quadratique moyenne (MSE) entre les données normalisées et les données reconstruites par l'autoencodeur pour chaque observation

    
    # Détection
    
    anomaly = bool(mse[0] > threshold)  # Détermination si l'observation est une anomalie en comparant l'erreur de reconstruction (MSE) avec le seuil défini (threshold). Si l'erreur dépasse le seuil, l'observation est considérée comme une anomalie (True), sinon elle est considérée comme normale (False).

    if anomaly:
        
        status = "Anomalie détectée"  # Indique que l'observation est considérée comme une anomalie (l'erreur de reconstruction dépasse le seuil défini)
        risk = "Elevé"  # Indique que le risque associé à l'observation est élevé (en raison de la détection d'une anomalie)
        
    else:
        
        status = "Client normal"  # Indique que l'observation est considérée comme normale (pas d'anomalie détectée)
        risk = "Faible"  # Indique que le risque associé à l'observation est faible (en raison de l'absence d'anomalie détectée)


    # Résultat


    return {
        
        "is_anomaly": anomaly,      # Indique si une anomalie a été détectée (True) ou non (False)
        "status": status,              # Retourne le statut de l'observation (anomalie détectée ou client normal)
        "risk_level": risk,            # Retourne le niveau de risque associé à l'observation (élevé ou faible)
        "reconstruction_error": round(float(mse[0]),8),  # On arrondit l'erreur de reconstruction à 8 décimales pour une meilleure lisibilité
        "threshold": round(float(threshold),8)  # On arrondit le seuil à 8 décimales pour une meilleure lisibilité
        }