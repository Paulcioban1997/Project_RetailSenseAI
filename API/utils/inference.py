import logging
import os
from concurrent.futures import ThreadPoolExecutor, TimeoutError as FutureTimeoutError
from typing import Any, Callable

from fastapi import HTTPException

logger = logging.getLogger("retailsense.endpoints")
INFERENCE_TIMEOUT_SECONDS = float(os.getenv("RETAILSENSE_INFERENCE_TIMEOUT_SECONDS", "45"))


def run_with_timeout(fn: Callable[[], Any], stage: str, timeout_seconds: float | None = None) -> Any:
    timeout = timeout_seconds or INFERENCE_TIMEOUT_SECONDS
    with ThreadPoolExecutor(max_workers=1) as executor:
        future = executor.submit(fn)
        try:
            return future.result(timeout=timeout)
        except FutureTimeoutError as exc:
            raise HTTPException(
                status_code=504,
                detail={
                    "error": "Inference timeout",
                    "stage": stage,
                    "timeout_seconds": timeout,
                },
            ) from exc


def log_endpoint_timing(
    endpoint: str,
    model_load_ms: float,
    preprocess_ms: float,
    predict_ms: float,
    total_ms: float,
    error: str | None = None,
    extra: str | None = None,
) -> None:
    logger_fn = logger.error if error else logger.info
    logger_fn(
        "==========\n"
        "Endpoint called: %s\n"
        "Model load time (ms): %.2f\n"
        "Preprocessing time (ms): %.2f\n"
        "Prediction time (ms): %.2f\n"
        "Total time (ms): %.2f\n"
        "Error: %s\n"
        "%s\n"
        "==========",
        endpoint,
        model_load_ms,
        preprocess_ms,
        predict_ms,
        total_ms,
        error or "none",
        extra or "",
    )


def internal_error(endpoint: str, exc: Exception) -> HTTPException:
    return HTTPException(
        status_code=500,
        detail={
            "error": "Inference failed",
            "endpoint": endpoint,
            "message": str(exc),
        },
    )


def model_unavailable_detail(missing: list[str], all_errors: dict[str, Any], max_error_len: int = 260) -> dict[str, Any]:
    filtered_errors: dict[str, Any] = {}
    for key in missing:
        raw = all_errors.get(key)
        if not isinstance(raw, dict):
            continue

        message = str(raw.get("error", ""))
        compact = message.splitlines()[0].strip() if message else ""
        if len(compact) > max_error_len:
            compact = compact[: max_error_len - 3] + "..."

        filtered_errors[key] = {
            "path": raw.get("path"),
            "error": compact or "Unavailable model artifact",
        }

    return {
        "error": "Model unavailable",
        "missing": missing,
        "model_errors": filtered_errors,
    }
