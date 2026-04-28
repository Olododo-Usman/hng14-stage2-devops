from fastapi import FastAPI, Response
import os, redis, uuid

app = FastAPI()

REDIS_URL = os.getenv("REDIS_URL", "redis://redis:6379")
r = redis.Redis.from_url(REDIS_URL)

@app.on_event("startup")
def startup():
    try:
        r.ping()
        print("✅ Connected to Redis")
    except redis.exceptions.ConnectionError as e:
        print(f"⚠️ Redis not ready: {e}")

@app.get("/health")
def health():
    return Response(content="OK", media_type="text/plain")


@app.post("/jobs")
def create_job():
    job_id = str(uuid.uuid4())
    r.lpush("job", job_id)
    r.hset(f"job:{job_id}", "status", "queued")
    return {"job_id": job_id}


@app.get("/jobs/{job_id}")
def get_job(job_id: str):
    status = r.hget(f"job:{job_id}", "status")
    if not status:
        return {"error": "not found"}
    return {"job_id": job_id, "status": status.decode()}
