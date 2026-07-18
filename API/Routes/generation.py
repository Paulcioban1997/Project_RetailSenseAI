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

        preprocess_started = time.perf_counter()
        
        # Fallback: Complete heuristic when any GAN assets are unavailable
        if scaler is None or features is None or generator is None:
            # Default RetailSense features when metadata unavailable
            if features is None:
                features = [
                    "order_id", "customer_id", "product_id", "order_status",
                    "customer_state", "delivery_days", "delay_days", "purchase_month",
                    "purchase_dow", "total_price", "total_freight", "total_weight",
                    "main_category", "payment_value", "max_installments", "payment_type",
                    "n_items", "review_score", "bad_review", "shipping_days"
                ]
            
            # Generate synthetic data using heuristic distributions
            synthetic_data = []
            for _ in range(count):
                row = {
                    "order_id": int(np.random.randint(1000000, 9999999)),
                    "customer_id": int(np.random.randint(100000, 999999)),
                    "product_id": int(np.random.randint(10000, 99999)),
                    "order_status": str(np.random.choice(["delivered", "shipped", "processing"])),
                    "customer_state": str(np.random.choice(["SP", "RJ", "MG", "BA", "RS", "CE", "SC"])),
                    "delivery_days": int(np.random.randint(1, 30)),
                    "delay_days": int(np.random.randint(-5, 15)),
                    "purchase_month": int(np.random.randint(1, 13)),
                    "purchase_dow": int(np.random.randint(0, 7)),
                    "total_price": float(np.random.uniform(10, 500)),
                    "total_freight": float(np.random.uniform(0, 100)),
                    "total_weight": float(np.random.uniform(0.1, 50)),
                    "main_category": str(np.random.choice(["electronics", "home", "fashion", "sports"])),
                    "payment_value": float(np.random.uniform(10, 500)),
                    "max_installments": int(np.random.randint(1, 13)),
                    "payment_type": str(np.random.choice(["credit_card", "debit_card", "boleto"])),
                    "n_items": int(np.random.randint(1, 10)),
                    "review_score": int(np.random.randint(1, 6)),
                    "bad_review": int(np.random.choice([0, 1])),
                    "shipping_days": int(np.random.randint(1, 30)),
                }
                synthetic_data.append(row)
            
            extra = f"count={count}; mode=complete_heuristic; features={len(features)}"
            preprocess_ms = (time.perf_counter() - preprocess_started) * 1000
            predict_ms = 0.0
            
            return {
                "message": f"{count} lignes synthetiques generees avec succes.",
                "generated_data": synthetic_data
            }
        
        # Normal mode: Use GAN or noise-based generation with scaler
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
            extra = f"count={count}; mode=noise_fallback; feature_dim={feature_dim}"
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