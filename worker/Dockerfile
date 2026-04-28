FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
RUN useradd -m appuser
USER appuser
HEALTHCHECK CMD python -c "import redis; print('ok')" || exit 1
CMD ["python", "worker.py"]

