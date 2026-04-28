FROM python:3.11-slim
RUN apt-get update && apt-get install -y curl
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
RUN useradd -m appuser
USER appuser
EXPOSE 8000
HEALTHCHECK CMD curl -f [localhost](http://localhost:8000/health) || exit 1
CMD ["uvicorn", "main:app", "--host=0.0.0.0", "--port=8000"]

