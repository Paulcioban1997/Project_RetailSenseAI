from fastapi import APIRouter, HTTPException, Query
import pandas as pd
import numpy as np
import time

from API.Models.load_models import MODELS
from API.utils.inference import internal_error, log_endpoint_timing, model_unavailable_detail, run_with_timeout

router = APIRouter()


@router.post("/generate/data", summary="Generer des donnees synthetiques")
def generate_data(count: int = Query(100, ge=1, le=1000, description="Nombre de lignes synthetiques a generer.")):
    endpoint = "/generate/synthetic"
    started = time.perf_counter()
    model_load_ms = 0.0
    preprocess_ms = 0.0
    predict_ms = 0.0
    err = None
    extra = None

    try:
        model_started = time.perf_counter()
        generator = MODELS.get("generator")
        scaler = MODELS.get("gan_scaler")
        features = MODELS.get("gan_features")
        model_load_ms = (time.perf_counter() - model_started) * 1000

        if scaler is None or features is None:
            missing = [k for k in ["gan_scaler", "gan_features"] if MODELS.get(k) is None]
            raise HTTPException(
                status_code=503,
                detail=model_unavailable_detail(missing, MODELS.get("__errors__", {})),
            )

        preprocess_started = time.perf_counter()
        fallback_mode = generator is None
        latent_dim = None
        if not fallback_mode:
            input_shape = getattr(generator, "input_shape", None)
            if isinstance(input_shape, list):
                input_shape = input_shape[0]
            if not isinstance(input_shape, tuple) or len(input_shape) < 2:
                fallback_mode = True
            else:
                latent_dim = int(input_shape[-1])
                if latent_dim <= 0:
                    fallback_mode = True

        if fallback_mode:
            feature_dim = len(features)
            if feature_dim <= 0:
                raise HTTPException(status_code=500, detail={"error": "Invalid GAN features metadata"})
            noise = np.random.normal(0, 1, (count, feature_dim)).astype(np.float32)
            extra = f"count={count}; mode=fallback; feature_dim={feature_dim}"
        else:
            noise = np.random.normal(0, 1, (count, latent_dim)).astype(np.float32)
            extra = f"count={count}; mode=generator; latent_dim={latent_dim}"
        preprocess_ms = (time.perf_counter() - preprocess_started) * 1000

        predict_started = time.perf_counter()
        if fallback_mode:
            generated = noise
        else:
            generated = run_with_timeout(
                lambda: generator.predict(noise, verbose=0),
                stage="gan_generate",
            )
        generated = scaler.inverse_transform(generated)
        predict_ms = (time.perf_counter() - predict_started) * 1000

        generated_df = pd.DataFrame(generated, columns=features)

        discrete_cols = ["purchase_month", "purchase_dow", "n_items", "max_installments", "review_score", "bad_review"]
        for col in discrete_cols:
            if col in generated_df.columns:
                generated_df[col] = generated_df[col].round()

        if "bad_review" in generated_df.columns:
            generated_df["bad_review"] = generated_df["bad_review"].clip(0, 1)

        generated_df = generated_df.round(4)
        generated_rows = generated_df.to_dict(orient="records")

        return {
            "message": f"{count} lignes synthetiques generees avec succes.",
            "generated_data": generated_rows
        }
    except HTTPException as exc:
        err = str(exc.detail)
        raise
    except Exception as exc:
        err = str(exc)
        raise internal_error(endpoint, exc)
    finally:
        total_ms = (time.perf_counter() - started) * 1000
        log_endpoint_timing(endpoint, model_load_ms, preprocess_ms, predict_ms, total_ms, error=err, extra=extra)
        MODELS.release(["generator"])