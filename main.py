import logging
import os

import uvicorn

logger = logging.getLogger("retailsense.main")


def main() -> None:
    host = "0.0.0.0"
    port = int(os.environ.get("PORT", "8000"))
    logger.info("Starting Uvicorn")
    logger.info("Uvicorn host=%s port=%s", host, port)
    uvicorn.run("API.app:app", host=host, port=port, log_level="info")


if __name__ == "__main__":
    main()
