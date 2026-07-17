from fastapi import FastAPI
from fastapi.responses import HTMLResponse, JSONResponse, Response
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