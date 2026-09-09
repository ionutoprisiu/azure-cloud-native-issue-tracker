from datetime import datetime
from enum import Enum

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="Cloud-Native Issue Tracker API")


class IssueStatus(str, Enum):
    open = "open"
    in_progress = "in_progress"
    closed = "closed"


class IssueCreate(BaseModel):
    title: str
    description: str


class Issue(BaseModel):
    id: int
    title: str
    description: str
    status: IssueStatus
    created_at: datetime


issues: list[Issue] = []
next_id = 1


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


@app.get("/issues")
def get_issues():
    return issues


@app.post("/issues", status_code=201)
def create_issue(issue: IssueCreate):
    global next_id

    new_issue = Issue(
        id=next_id,
        title=issue.title,
        description=issue.description,
        status=IssueStatus.open,
        created_at=datetime.now()
    )

    issues.append(new_issue)
    next_id += 1

    return new_issue


@app.patch("/issues/{issue_id}/status")
def update_issue_status(issue_id: int, status: IssueStatus):
    for issue in issues:
        if issue.id == issue_id:
            issue.status = status
            return issue

    raise HTTPException(status_code=404, detail="Issue not found")


@app.delete("/issues/{issue_id}", status_code=204)
def delete_issue(issue_id: int):
    for issue in issues:
        if issue.id == issue_id:
            issues.remove(issue)
            return

    raise HTTPException(status_code=404, detail="Issue not found")