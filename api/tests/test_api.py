from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_health():
    res = client.get("/health")
    assert res.status_code == 200

def test_root():
    res = client.get("/")
    assert res.status_code == 200

def test_invalid():
    res = client.get("/invalid")
    assert res.status_code == 404
