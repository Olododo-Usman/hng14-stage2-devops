# FIXES.md

## 1. Invalid Docker Healthcheck Syntax

**File:** docker-compose.yml
**Line:** (healthcheck under api service)

**Problem:**
Healthcheck used Markdown-style URL:

```
curl -f [localhost](http://localhost:8000/health)
```

This is invalid shell syntax and caused:

```
/bin/sh: 1: Syntax error: "(" unexpected
```

**Impact:**
Docker marked the API container as **unhealthy**, preventing dependent services (worker) from starting.

**Fix:**
Replaced with valid curl command:

```
curl -f http://localhost:8000/health
```

---

## 2. Missing API Healthcheck

**File:** docker-compose.yml

**Problem:**
The API service did not initially have a valid healthcheck, but other services depended on it using:

```
condition: service_healthy
```

**Impact:**
Worker service failed to start because Docker waited indefinitely for API to become healthy.

**Fix:**
Added proper healthcheck:

```
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
  interval: 10s
  timeout: 5s
  retries: 5
```

---

## 3. Incomplete docker-compose.yml Configuration

**File:** docker-compose.yml

**Problem:**
Frontend service definition was incomplete:

* `depends_on` not finished
* `networks` not defined

**Impact:**
Docker Compose failed to parse or run correctly.

**Fix:**
Completed the service definition and added:

```
networks:
  - backend
```

Also added global networks section:

```
networks:
  backend:
```

---

## 4. Deprecated `version` Field in docker-compose

**File:** docker-compose.yml

**Problem:**
Used:

```
version: '3.8'
```

**Impact:**
Warning:

```
the attribute `version` is obsolete
```

**Fix:**
Removed the version field since newer Docker Compose versions no longer require it.

---

## 5. Running docker-compose from Wrong Directory

**Problem:**
Executed:

```
cd api
docker compose up
```

Instead of project root.

**Impact:**
Docker could not correctly locate `docker-compose.yml` and services failed to start properly.

**Fix:**
Always run from project root:

```
cd ~/hng14-stage2-devops
docker compose up
```

---

## 6. API Container Marked Unhealthy Despite Running

**Problem:**
Container was running but flagged as unhealthy.

**Root Cause:**
Broken healthcheck command (not application failure).

**Impact:**
Misleading debugging — system appeared broken even though API was working.

**Fix:**
Corrected healthcheck syntax.

---

## 7. Potential Missing `/health` Endpoint

**File:** api/main.py

**Problem:**
Healthcheck depended on:

```
/health
```
But endpoint may not exist.

**Impact:**
Healthcheck fails even if API is running.

**Fix:**
Added endpoint:

```python
@app.get("/health")
def health():
    return {"status": "ok"}
```

## 8. Redis Connection Misconfiguration (Common Container Issue)

**File:** API / Worker configs

**Problem:**
Using:
```
localhost:6379
```
**Impact:**
Fails inside Docker because services communicate via service names.

**Fix:**
Updated to:
```
redis://redis:6379


## 9. Services Not Waiting for Healthy Dependencies

**File:** docker-compose.yml

**Problem:**
Services may start before dependencies are ready.

**Impact:**
Race conditions and startup failures.

Fix:
Used:
condition: service_healthy
```
for proper dependency management.

