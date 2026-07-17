# RetailSense AI

Projet d integration CDI

Auteur: Mircea Paul Cioban

## Objectif

RetailSense AI est une plateforme d analyse intelligente des donnees commerciales basee sur:

- FastAPI (backend)
- Flutter (frontend mobile/desktop)
- Machine Learning et Deep Learning
- Docker

## Fonctionnalites API

- Prediction bad review
- Prediction demande commande
- Prevision hebdomadaire (RNN)
- Prediction prix
- Segmentation clients
- Detection anomalie
- Generation clients synthetiques
- Analyse de sentiment
- Recommandation produits

## Lancer en local

Prerequis:

- Python 3.11+
- pip

Installation:

```bash
pip install -r requirements.txt
```

Execution API:

```bash
uvicorn API.app:app --host 0.0.0.0 --port 8000
```

Test:

- API: http://127.0.0.1:8000
- Docs: http://127.0.0.1:8000/docs

## Variables d environnement

Le backend utilise ces variables (optionnelles) pour les chemins modeles:

- RETAILSENSE_PROJECT_ROOT
- RETAILSENSE_ML_DIR
- RETAILSENSE_DL_DIR
- RETAILSENSE_CLASSIFICATION_DIR
- RETAILSENSE_REGRESSION_DIR
- RETAILSENSE_CLUSTERING_DIR
- RETAILSENSE_AUTOENCODER_DIR
- RETAILSENSE_GAN_DIR
- RETAILSENSE_GNN_DIR
- RETAILSENSE_TRANSFORMER_DIR

Voir le fichier .env.example pour un exemple.

## Procfile

Un `Procfile` est inclus pour clarifier la commande de demarrage:

```bash
web: uvicorn API.app:app --host 0.0.0.0 --port $PORT
```

## Notes importantes

- Si les modeles sont volumineux, verifier la taille du repo et le temps de build sur Render.
- Si certaines routes utilisent des modeles DL (torch/transformers), le demarrage peut etre plus long.
