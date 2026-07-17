FROM python:3.11

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt ./requirements.txt

RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir torch transformers sentencepiece

COPY . .

EXPOSE 8000

CMD ["python", "-m", "uvicorn", "API.app:app", "--host", "0.0.0.0", "--port", "8000"]