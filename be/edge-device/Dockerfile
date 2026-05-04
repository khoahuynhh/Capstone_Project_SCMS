FROM python:3.10-slim

WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1 \
    libglib2.0-0 \
    libstdc++6 \
    libgomp1 \
    libjpeg62-turbo \
    libpng16-16 \
    libtiff6 \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.runtime.txt .
RUN python -m pip install --upgrade pip setuptools wheel \
    && pip install --prefer-binary -r requirements.runtime.txt

# Copy application code
COPY . .

# Create directories
RUN mkdir -p /app/data/transactions /app/data/embeddings /app/models

CMD ["uvicorn", "edge_api:app", "--host", "0.0.0.0", "--port", "8001"]
