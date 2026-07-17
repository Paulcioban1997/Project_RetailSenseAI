import os
from pathlib import Path
from dotenv import load_dotenv

# Charge automatiquement les variables du fichier .env en local.
load_dotenv()


def _resolve_existing_path(env_key: str, fallback: Path) -> Path:
    raw = os.getenv(env_key)
    fallback = fallback.resolve()
    if not raw:
        return fallback

    candidate = Path(raw).resolve()
    if candidate.exists():
        return candidate

    return fallback

# Racine projet: peut etre forcee par variable d'environnement
# Ex: RETAILSENSE_PROJECT_ROOT=C:/app
BASE_DIR = _resolve_existing_path(
    "RETAILSENSE_PROJECT_ROOT",
    Path(__file__).resolve().parent.parent,
)

# Dossiers principaux (surchargeables)
ML_DIR = _resolve_existing_path(
    "RETAILSENSE_ML_DIR",
    BASE_DIR / "Machine-Learning",
)

DL_DIR = _resolve_existing_path(
    "RETAILSENSE_DL_DIR",
    BASE_DIR / "Deep-Learning",
)

# Sous-dossiers ML
CLASSIFICATION_DIR = _resolve_existing_path(
    "RETAILSENSE_CLASSIFICATION_DIR",
    ML_DIR / "Models_Classification",
)

REGRESSION_DIR = _resolve_existing_path(
    "RETAILSENSE_REGRESSION_DIR",
    ML_DIR / "Models_Regression",
)

CLUSTERING_DIR = _resolve_existing_path(
    "RETAILSENSE_CLUSTERING_DIR",
    ML_DIR / "Models_Clustering",
)

# Sous-dossiers DL
AUTOENCODER_DIR = _resolve_existing_path(
    "RETAILSENSE_AUTOENCODER_DIR",
    DL_DIR / "Models_AutoEncoder",
)

GAN_DIR = _resolve_existing_path(
    "RETAILSENSE_GAN_DIR",
    DL_DIR / "Models_GAN",
)

GNN_DIR = _resolve_existing_path(
    "RETAILSENSE_GNN_DIR",
    DL_DIR / "Models_GNN",
)

TRANSFORMER_DIR = _resolve_existing_path(
    "RETAILSENSE_TRANSFORMER_DIR",
    DL_DIR / "Models_Transformer" / "xlm_roberta_sentiment",
)