from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from pydantic import BaseModel

from database import Base, engine, get_db
from models import Issue, IssueStatus


Base.metadata.create_all(bind=engine)

DbSession = Annotated[Session, Depends(get_db)]

app = FastAPI(title="Cloud-Native Issue Tracker API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

class IssueCreate(BaseModel):
    title: str
    description: str


@app.get("/health")
def health():
    return {
        "status": "ok"
    }

@app.get("/issues")
def get_issues(db: DbSession):
    issues = db.query(Issue).all()
    return issues

@app.get("/issues/{issue_id}")
def get_issue(issue_id: int, db: DbSession):
    issue = db.query(Issue).filter(Issue.id == issue_id).first()

    if issue is None:
        raise HTTPException(status_code=404, detail="Issue not found")

    return issue

@app.post("/issues", status_code=201)
def create_issue(issue: IssueCreate, db: DbSession):
    new_issue = Issue(
        title=issue.title,
        description=issue.description
    )

    db.add(new_issue)
    db.commit()
    db.refresh(new_issue)

    return new_issue

@app.patch("/issues/{issue_id}/status")
def update_issue_status(issue_id: int, status: IssueStatus, db: DbSession):
    issue = db.query(Issue).filter(Issue.id == issue_id).first()

    if issue is None:
        raise HTTPException(status_code=404, detail="Issue not found")

    issue.status = status

    db.commit()
    db.refresh(issue)

    return issue

@app.delete("/issues/{issue_id}", status_code=204)
def delete_issue(issue_id: int, db: DbSession):
    issue = db.query(Issue).filter(Issue.id == issue_id).first()

    if issue is None:
        raise HTTPException(status_code=404, detail="Issue not found")

    db.delete(issue)
    db.commit()