from fastapi import FastAPI
from API.Routes.churn import router as churn_router
from API.Routes.segmentation import router as segmentation_router
from API.Routes.demand import demand_router
from API.Routes.anomaly import router as anomaly_router
from API.Routes.generation import router as generation_router
from API.Routes.sentiment import router as sentiment_router
from API.Routes.recommendation import router as recommendation_router

app = FastAPI(
    title="RetailSense AI API",
    description="API REST pour les modèles de Machine Learning et Deep Learning.",
    version="1.0.0"
)                     # Initialisation de l'application FastAPI avec un titre, une description et une version

app.include_router(churn_router) # Incursion des routes pour la prédiction de churn
app.include_router(segmentation_router) # Incursion des routes pour la segmentation
app.include_router(demand_router)      # Incursion des routes pour la prévision de la demande
app.include_router(anomaly_router)     # Inclusion des routes pour la détection d'anomalies
app.include_router(generation_router)  # Inclusion des routes pour la génération de clients synthétiques
app.include_router(sentiment_router)   # Inclusion des routes pour l'analyse de sentiment
app.include_router(recommendation_router)  # Inclusion des routes pour les recommandations



@app.get("/")  # Route GET pour la page d'accueil de l'API
def home():
    return {
        "message": "Bienvenue sur RetailSense AI API",
        "status": "Online",
        "version": "1.0.0"
    }  # Retourne un message de bienvenue, le statut et la version de l'API