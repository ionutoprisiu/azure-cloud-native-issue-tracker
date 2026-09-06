from fastapi import FastAPI

app = FastAPI(title="Cloud-Native Issue Tracker API")


@app.get("/")
def root():
    return {
        "service": "issue-tracker-api",
        "status": "running"
    }


@app.get("/health")
def health():
    return {
        "status": "ok"
    }