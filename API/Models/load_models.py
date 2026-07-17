print("HELLO RETAILSENSE")

import joblib
import json 
import torch
from pathlib import Path
import os

os.environ.setdefault("KERAS_BACKEND", "torch")

import warnings
warnings.filterwarnings("ignore")  # Désactive les avertissements de dépréciation et autres avertissements

import logging
from keras.models import load_model
from transformers import AutoTokenizer
from transformers import (
    XLMRobertaTokenizerFast,
    AutoModelForSequenceClassification,
)

from API.config import (
    CLASSIFICATION_DIR,
    REGRESSION_DIR,
    DL_DIR,
    CLUSTERING_DIR,
    AUTOENCODER_DIR,
    GAN_DIR,
    GNN_DIR,
    TRANSFORMER_DIR
)
    
MODELS_DIR = Path(__file__).resolve().parent  # Dossier contenant le fichier load_models.py
WEEKLY_DEMAND_DIR = DL_DIR / "Models_LSTM"

# CHARGEMENT DES MODELES

print("Chargement des modèles RetailSense AI...")


# MACHINE LEARNING


# Classification ( / Classification client)

gradient_boosting_model = joblib.load(
    CLASSIFICATION_DIR / "gradient_boosting_optimize_grid.pkl"
)
print("Gradient Boosting chargé.")

# Quantiles_RFM

quantiles = joblib.load(
    MODELS_DIR / "rfm_quantiles.pkl"
)
print("Quantiles RFM chargé.")

# Régression (Prévision de la demande)

xgboost_demand_model = joblib.load(
    REGRESSION_DIR / "xgboost_regressor_regression_model.pkl"
)
print("XGBoost demande chargé.")

xgboost_price_model = joblib.load(
    REGRESSION_DIR / "xgboost_regression_price.pkl"
)
print("XGBoost prix chargé.")

# Prévision hebdomadaire de la demande (RNN)
weekly_demand_model = load_model(
    WEEKLY_DEMAND_DIR / "best_rnn_n_items_weekly.keras"
)
print("RNN hebdo demande chargé.")

weekly_demand_scaler = joblib.load(
    WEEKLY_DEMAND_DIR / "scaler_n_items_weekly.joblib"
)
print("Scaler hebdo demande chargé.")

with open(
    WEEKLY_DEMAND_DIR / "best_weekly_demand_model_metadata.json",
    "r",
    encoding="utf-8"
) as f:
    weekly_demand_metadata = json.load(f)

print("Metadata hebdo demande chargées.")

# Clustering (Segmentation)

kmeans_rfm = joblib.load(
    CLUSTERING_DIR / "kmeans_rfm.pkl"
)

print("KMeans RFM chargé.")

scaler_rfm = joblib.load(
    CLUSTERING_DIR / "scaler_rfm.pkl"
)

print("Scaler RFM chargé.")

# DEEP LEARNING

# AutoEncoder

autoencoder_model = load_model(
    AUTOENCODER_DIR / "autoencoder_anomaly_detector.keras"
)

print("AutoEncoder chargé.")

autoencoder_scaler = joblib.load(
    AUTOENCODER_DIR / "scaler.pkl"
)

print("Scaler AutoEncoder chargé.")

autoencoder_threshold = joblib.load(
    AUTOENCODER_DIR / "threshold.pkl"
)

print("Threshold AutoEncoder chargé.")

with open(
    AUTOENCODER_DIR / "features.json",
    "r",
    encoding="utf-8"
) as f:

    autoencoder_features = json.load(f)

print("Features AutoEncoder chargées.")

# GAN

generator_model = load_model(
    GAN_DIR / "generator.keras"
)

print("GAN chargé.")

gan_scaler = joblib.load(
    GAN_DIR / "scaler.pkl"
)

print("Scaler GAN chargé.")

with open(
    GAN_DIR / "features.json",
    "r",
    encoding="utf-8"
) as f:

    gan_features = json.load(f)

print("Features GAN chargées.")

# GNN

gnn_model_state = torch.load(
    GNN_DIR / "gcn_model.pth",
    map_location="cpu"
)          # map_location="cpu" permet de charger le modèle sur le CPU, même s'il a été entraîné sur un GPU

print("GNN chargé.")

with open(
    GNN_DIR / "recommendations.json",
    "r",
    encoding="utf-8"
) as f:
    recommendations = json.load(f)

print("Recommendations GNN chargées.")

# Transformer

tokenizer = XLMRobertaTokenizerFast.from_pretrained(
    TRANSFORMER_DIR
)

transformer_model = AutoModelForSequenceClassification.from_pretrained(
    TRANSFORMER_DIR
)

print("Transformer chargé.")


# Ajout d'un dictionnaire pour stocker les modèles et les tokenizer

MODELS = {
    "gradient_boosting": gradient_boosting_model,
    "quantiles": quantiles,
    "demand_model": xgboost_demand_model,
    "price_model": xgboost_price_model,
    "weekly_demand_model": weekly_demand_model,
    "weekly_demand_scaler": weekly_demand_scaler,
    "weekly_demand_metadata": weekly_demand_metadata,
    "kmeans": kmeans_rfm,
    "scaler_rfm": scaler_rfm,

    "autoencoder": autoencoder_model,
    "autoencoder_scaler": autoencoder_scaler,
    "autoencoder_threshold": autoencoder_threshold,
    "autoencoder_features": autoencoder_features,

    "generator": generator_model,
    "gan_scaler": gan_scaler,
    "gan_features": gan_features,
    "gnn_state": gnn_model_state,
    "recommendations": recommendations,
    "transformer": transformer_model,
    "tokenizer": tokenizer,
}