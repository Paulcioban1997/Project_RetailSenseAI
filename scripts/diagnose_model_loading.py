import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from API.Models.load_models import (  # noqa: E402
    startup_diagnostics,
    endpoint_model_status,
    MODEL_ERRORS,
)


def main() -> None:
    report = startup_diagnostics(preload_models=True)
    report["endpoint_models"] = endpoint_model_status()
    report["model_errors"] = dict(MODEL_ERRORS)
    print(json.dumps(report, indent=2, ensure_ascii=True))


if __name__ == "__main__":
    main()
