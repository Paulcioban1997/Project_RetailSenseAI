from fastapi import APIRouter, HTTPException
import torch
import time

from API.Models.load_models import MODELS
from API.schemas import SentimentInput
from API.utils.inference import internal_error, log_endpoint_timing, run_with_timeout

router = APIRouter()

# Labels des classes de sentiment
labels = {
    1: "Very Bad",
    2: "Bad",
    3: "Average",
    4: "Good",
    5: "Excellent"
}                    # Dictionnaire associant les scores de sentiment aux étiquettes correspondantes pour une meilleure interprétation des résultats

@router.post("/predict/sentiment", summary="Predire le sentiment d'un avis client")
def predict_sentiment(data: SentimentInput):
    endpoint = "/predict/sentiment"
    started = time.perf_counter()
    model_load_ms = 0.0
    preprocess_ms = 0.0
    predict_ms = 0.0
    err = None
    extra = None

    try:
        model_started = time.perf_counter()
        tokenizer = MODELS.get("tokenizer")
        model = MODELS.get("transformer")
        model_load_ms = (time.perf_counter() - model_started) * 1000

        if tokenizer is None or model is None:
            raise HTTPException(
                status_code=503,
                detail={
                    "error": "Model unavailable",
                    "missing": [k for k in ["tokenizer", "transformer"] if MODELS.get(k) is None],
                    "model_errors": MODELS.get("__errors__", {}),
                },
            )

        preprocess_started = time.perf_counter()
        text = (data.text or "").strip()
        if not text:
            raise HTTPException(status_code=422, detail={"error": "Text cannot be empty"})

        inputs = tokenizer(
            text,
            return_tensors="pt",
            truncation=True,
            padding=True,
            max_length=256,
        )

        device = getattr(model, "device", torch.device("cpu"))
        inputs = {k: v.to(device) for k, v in inputs.items()}
        extra = f"tokenized_shape={tuple(inputs['input_ids'].shape)}; device={device}"
        preprocess_ms = (time.perf_counter() - preprocess_started) * 1000

        predict_started = time.perf_counter()
        with torch.no_grad():
            outputs = run_with_timeout(lambda: model(**inputs), stage="sentiment_predict")
            probabilities = torch.softmax(outputs.logits, dim=1)
            _, prediction = torch.max(probabilities, dim=1)
        predict_ms = (time.perf_counter() - predict_started) * 1000

        review_score = int(prediction.item()) + 1
        label = labels.get(review_score, "Unknown")

        return {
            "review_score": review_score,
            "label": label,
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
        MODELS.release(["tokenizer", "transformer"])