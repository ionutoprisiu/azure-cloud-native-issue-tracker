from fastapi import Depends, FastAPI
from sqlalchemy.orm import Session

from database import get_db
from models import Issue


app = FastAPI(title="Cloud-Native Issue Tracker API")


@app.get("/health")
def health():
    return {
        "status": "ok"
    }


@app.get("/issues")
def get_issues(db: Session = Depends(get_db)):
    issues = db.query(Issue).all()
    return issues