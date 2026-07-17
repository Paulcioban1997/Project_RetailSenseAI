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

Test:


- API: http://127.0.0.1:8000
- Docs: http://127.0.0.1:8000/docs
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

<<<<<<< HEAD
=======
Important:

- `.env` est pour ton developpement local uniquement.
- `.env.example` est un modele partage pour le deploiement.
- Sur Render, les variables definies dans l interface Render ou `render.yaml` ont priorite.

## Deploiement sur Render

### Option 1 (recommandee): Web Service Python

1. Pousser le projet sur GitHub.
2. Sur Render: New + > Web Service.
3. Connecter le repo.
4. Configurer:
	- Runtime: Python 3
	- Build Command: `pip install -r requirements.txt`
	- Start Command: `uvicorn API.app:app --host 0.0.0.0 --port $PORT`
6. Deploy.

### Option 2: Blueprint (render.yaml)

Le projet inclut un fichier `render.yaml`. Sur Render:

1. New + > Blueprint.

>>>>>>> 7c458e9 (Clarify env template and Render deployment notes)
## Procfile
```bash
web: uvicorn API.app:app --host 0.0.0.0 --port $PORT
```

- Si les modeles sont volumineux, verifier la taille du repo et le temps de build sur Render.
- Si certaines routes utilisent des modeles DL (torch/transformers), le demarrage peut etre plus long.
<<<<<<< HEAD
=======

## Strategie modeles (recommandee)

Pour que toutes les routes ML/DL fonctionnent en production, il faut que les artefacts modeles soient disponibles sur Render.

Option A (simple): commit des modeles dans le repo

- Avantage: deploiement direct.
- Inconvenient: repo lourd, push plus lent.

Option B (propre): stockage externe + telechargement au demarrage

- Stocker les modeles sur un bucket (S3/R2/GCS) ou release GitHub.
- Telecharger les fichiers au build/debut de service vers les dossiers attendus.
- Garder le code source leger.

Option C (intermediaire): Git LFS

- Pousser les gros fichiers via LFS.
- Garder une structure unique dans le repo, avec gestion des poids volumineux.
>>>>>>> 7c458e9 (Clarify env template and Render deployment notes)
