from fastapi import APIRouter, Query
import pandas as pd
import numpy as np

from API.Models.load_models import MODELS

router = APIRouter()


@router.post("/generate/data", summary="Generer des donnees synthetiques")
def generate_data(count: int = Query(100, ge=1, le=1000, description="Nombre de lignes synthetiques a generer.")):

    
    # Chargement des ressources


    generator = MODELS["generator"]
    scaler = MODELS["gan_scaler"]
    features = MODELS["gan_features"]

    
    # Génération de nouvelles lignes synthétiques
    

    latent_dim = generator.input_shape[1]  # On récupère la dimension de l'espace latent à partir de la forme d'entrée du générateur

    noise = np.random.normal(0,1,(count, latent_dim)) # On génère un vecteur de bruit aléatoire à partir d'une distribution normale pour alimenter le générateur


    generated = generator.predict(
        noise,
        verbose=0
    )                        # On utilise le générateur pour créer un nouveau client synthétique à partir du vecteur de bruit

    
    # Retour à l'échelle réelle

    generated = scaler.inverse_transform(generated)  # On utilise le scaler pour transformer les données générées à l'échelle réelle des features

    generated_df = pd.DataFrame(generated,columns=features)  # On crée un DataFrame pandas à partir des données générées et on utilise les noms de colonnes des features

    # Arrondir / remettre en forme quelques colonnes discrètes
    discrete_cols = ["purchase_month", "purchase_dow", "n_items", "max_installments", "review_score", "bad_review"]
    for col in discrete_cols:
        if col in generated_df.columns:
            generated_df[col] = generated_df[col].round()

    if "bad_review" in generated_df.columns:
        generated_df["bad_review"] = generated_df["bad_review"].clip(0, 1)

    generated_df = generated_df.round(4)

    generated_rows = generated_df.to_dict(orient="records")

    return {
        "message": f"{count} lignes synthétiques générées avec succès.",
        "generated_data": generated_rows
        }