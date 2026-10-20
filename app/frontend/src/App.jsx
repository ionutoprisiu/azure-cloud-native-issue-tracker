import { useEffect, useState } from "react";
import "./App.css";

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:8000";

function App() {
  const [issues, setIssues] = useState([]);
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");

  const loadIssues = async () => {
    const response = await fetch(`${API_URL}/issues`);
    const data = await response.json();
    setIssues(data);
  };

  const createIssue = async (event) => {
    event.preventDefault();

    await fetch(`${API_URL}/issues`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        title,
        description,
      }),
    });

    setTitle("");
    setDescription("");

    loadIssues();
  };

  const updateStatus = async (id, status) => {
    await fetch(`${API_URL}/issues/${id}/status?status=${status}`, {
      method: "PATCH",
    });

    loadIssues();
  };

  const deleteIssue = async (id) => {
    await fetch(`${API_URL}/issues/${id}`, {
      method: "DELETE",
    });

    loadIssues();
  };

  useEffect(() => {
    loadIssues();
  }, []);

  return (
    <main className="container">
      <h1>Cloud-Native Issue Tracker</h1>

      <form onSubmit={createIssue} className="issue-form">
        <input
          type="text"
          placeholder="Issue title"
          value={title}
          onChange={(event) => setTitle(event.target.value)}
          required
        />

        <textarea
          placeholder="Description"
          value={description}
          onChange={(event) => setDescription(event.target.value)}
          required
        />

        <button type="submit">Create Issue</button>
      </form>

      <section className="issues">
        {issues.map((issue) => (
          <article key={issue.id} className="issue">
            <h2>{issue.title}</h2>
            <p>{issue.description}</p>
            <p>
              Status: <strong>{issue.status}</strong>
            </p>

            <div className="actions">
              <button onClick={() => updateStatus(issue.id, "in_progress")}>
                In Progress
              </button>

              <button onClick={() => updateStatus(issue.id, "closed")}>
                Close
              </button>

              <button onClick={() => deleteIssue(issue.id)}>
                Delete
              </button>
            </div>
          </article>
        ))}
      </section>
    </main>
  );
}

export default App;