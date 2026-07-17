import os
from pathlib import Path

# Racine projet: peut etre forcee par variable d'environnement
# Ex: RETAILSENSE_PROJECT_ROOT=C:/app
BASE_DIR = Path(
    os.getenv(
        "RETAILSENSE_PROJECT_ROOT",
        str(Path(__file__).resolve().parent.parent),
    )
).resolve()

# Dossiers principaux (surchargeables)
ML_DIR = Path(
    os.getenv("RETAILSENSE_ML_DIR", str(BASE_DIR / "Machine-Learning"))
).resolve()

DL_DIR = Path(
    os.getenv("RETAILSENSE_DL_DIR", str(BASE_DIR / "Deep-Learning"))
).resolve()

# Sous-dossiers ML
CLASSIFICATION_DIR = Path(
    os.getenv("RETAILSENSE_CLASSIFICATION_DIR", str(ML_DIR / "Models_Classification"))
).resolve()

REGRESSION_DIR = Path(
    os.getenv("RETAILSENSE_REGRESSION_DIR", str(ML_DIR / "Models_Regression"))
).resolve()

CLUSTERING_DIR = Path(
    os.getenv("RETAILSENSE_CLUSTERING_DIR", str(ML_DIR / "Models_Clustering"))
).resolve()

# Sous-dossiers DL
AUTOENCODER_DIR = Path(
    os.getenv("RETAILSENSE_AUTOENCODER_DIR", str(DL_DIR / "Models_AutoEncoder"))
).resolve()

GAN_DIR = Path(
    os.getenv("RETAILSENSE_GAN_DIR", str(DL_DIR / "Models_GAN"))
).resolve()

GNN_DIR = Path(
    os.getenv("RETAILSENSE_GNN_DIR", str(DL_DIR / "Models_GNN"))
).resolve()

TRANSFORMER_DIR = Path(
    os.getenv(
        "RETAILSENSE_TRANSFORMER_DIR",
        str(DL_DIR / "Models_Transformer" / "xlm_roberta_sentiment"),
    )
).resolve()