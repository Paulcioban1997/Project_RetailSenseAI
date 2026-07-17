from fastapi import FastAPI
from fastapi.responses import HTMLResponse, JSONResponse, Response
import logging
import os
import platform
from API.config import (
    BASE_DIR,
    ML_DIR,
    DL_DIR,
    CLASSIFICATION_DIR,
    REGRESSION_DIR,
    CLUSTERING_DIR,
    AUTOENCODER_DIR,
    GAN_DIR,
    GNN_DIR,
    TRANSFORMER_DIR,
)
from API.Models.load_models import (
    startup_diagnostics,
    endpoint_model_status,
    get_model_load_stats,
    MODEL_ERRORS,
)
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

logger = logging.getLogger("retailsense.api")

app.include_router(churn_router) # Incursion des routes pour la prédiction de churn
app.include_router(segmentation_router) # Incursion des routes pour la segmentation
app.include_router(demand_router)      # Incursion des routes pour la prévision de la demande
app.include_router(anomaly_router)     # Inclusion des routes pour la détection d'anomalies
app.include_router(generation_router)  # Inclusion des routes pour la génération de clients synthétiques
app.include_router(sentiment_router)   # Inclusion des routes pour l'analyse de sentiment
app.include_router(recommendation_router)  # Inclusion des routes pour les recommandations

STARTUP_REPORT = {}


@app.on_event("startup")
def startup_checks():
    global STARTUP_REPORT
    logger.info("FastAPI startup sequence initiated")
    logger.info("Python runtime: %s", platform.python_version())
    logger.info("PORT env value: %s", os.getenv("PORT", "<not-set>"))
    logger.info("Lazy model loading is enabled")
    try:
        # Do not preload heavy models on startup; keep startup fast for Render port scan.
        STARTUP_REPORT = startup_diagnostics(preload_models=False)
        logger.info("Startup diagnostics initialized without preloading models")
    except Exception as exc:
        STARTUP_REPORT = {
            "status": "degraded",
            "error": str(exc),
        }
        logger.exception("Startup diagnostics failed, continuing without blocking server")



@app.get("/", response_class=HTMLResponse)  # Route GET pour la page d'accueil de l'API
def home():
        return """
        <!DOCTYPE html>
        <html lang="fr">
            <head>
                <meta charset="utf-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1" />
                <title>RetailSense AI API</title>
                <style>
                    body {
                        margin: 0;
                        font-family: Arial, sans-serif;
                        background: #0f172a;
                        color: #e2e8f0;
                    }
                    main {
                        max-width: 900px;
                        margin: 0 auto;
                        padding: 48px 20px;
                    }
                    .card {
                        background: #111827;
                        border: 1px solid #334155;
                        border-radius: 16px;
                        padding: 24px;
                        margin-top: 24px;
                    }
                    h1, h2 {
                        margin-top: 0;
                    }
                    code {
                        color: #93c5fd;
                    }
                    ul {
                        line-height: 1.8;
                    }
                    a {
                        color: #38bdf8;
                    }
                </style>
            </head>
            <body>
                <main>
                    <h1>RetailSense AI API</h1>
                    <p>Le service est en ligne et les modeles de prediction sont exposes via l API.</p>

                    <div class="card">
                        <h2>Statut</h2>
                        <ul>
                            <li><code>GET /health</code> : verification de sante</li>
                            <li><code>GET /docs</code> : documentation Swagger</li>
                            <li><code>GET /openapi.json</code> : schema OpenAPI</li>
                        </ul>
                    </div>

                    <div class="card">
                        <h2>Routes principales</h2>
                        <ul>
                            <li><code>POST /predict/bad-review</code></li>
                            <li><code>POST /predict/demand</code></li>
                            <li><code>POST /predict/weekly-demand</code></li>
                            <li><code>POST /predict/price</code></li>
                            <li><code>POST /segment/customer</code></li>
                            <li><code>POST /detect/anomaly</code></li>
                            <li><code>POST /generate/data</code></li>
                            <li><code>POST /predict/sentiment</code></li>
                            <li><code>POST /recommend/products</code></li>
                        </ul>
                    </div>
                </main>
            </body>
        </html>
        """


@app.head("/")
def home_head():
        return Response(status_code=200)


@app.get("/health")
def health():
        return JSONResponse(
                {
                        "status": "ok",
                        "service": "RetailSense AI API",
                        "version": "1.0.0",
                }
        )


@app.get("/health/startup")
def health_startup():
    return {
        "status": "ok",
        "startup": STARTUP_REPORT,
        "endpoint_models": endpoint_model_status(),
        "model_load_stats": get_model_load_stats(),
        "model_errors": dict(MODEL_ERRORS),
    }


@app.get("/health/models")
def health_models():
    checks = {
        "gradient_boosting": (
            (CLASSIFICATION_DIR / "gradient_boosting_model.pkl").exists()
            or (CLASSIFICATION_DIR / "gradient_boosting_optimize_grid.pkl").exists()
        ),
        "demand_model": (REGRESSION_DIR / "xgboost_regressor_regression_model.pkl").exists(),
        "price_model": (REGRESSION_DIR / "xgboost_regression_price.pkl").exists(),
        "kmeans": (CLUSTERING_DIR / "kmeans_rfm.pkl").exists(),
        "scaler_rfm": (CLUSTERING_DIR / "scaler_rfm.pkl").exists(),
        "weekly_model": (DL_DIR / "Models_LSTM" / "best_rnn_n_items_weekly.keras").exists(),
        "autoencoder": (AUTOENCODER_DIR / "autoencoder_anomaly_detector.keras").exists(),
        "generator": (GAN_DIR / "generator.keras").exists(),
        "gnn_state": (GNN_DIR / "gcn_model.pth").exists(),
        "recommendations": (GNN_DIR / "recommendations.json").exists(),
        "transformer_config": (TRANSFORMER_DIR / "config.json").exists(),
        "transformer_weights": (TRANSFORMER_DIR / "model.safetensors").exists(),
    }

    return {
        "status": "ok",
        "paths": {
            "BASE_DIR": str(BASE_DIR),
            "ML_DIR": str(ML_DIR),
            "DL_DIR": str(DL_DIR),
            "CLASSIFICATION_DIR": str(CLASSIFICATION_DIR),
            "REGRESSION_DIR": str(REGRESSION_DIR),
            "CLUSTERING_DIR": str(CLUSTERING_DIR),
            "AUTOENCODER_DIR": str(AUTOENCODER_DIR),
            "GAN_DIR": str(GAN_DIR),
            "GNN_DIR": str(GNN_DIR),
            "TRANSFORMER_DIR": str(TRANSFORMER_DIR),
        },
        "files": checks,
    }