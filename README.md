# 🌐 Survivor Network: AI-Powered Graph Analytics

![Python](https://img.shields.io/badge/Python-3.11+-blue.svg)
![React](https://img.shields.io/badge/React-Frontend-61DAFB.svg?logo=react)
![Google Cloud](https://img.shields.io/badge/Google_Cloud-Vertex_AI-4285F4.svg?logo=googlecloud)
![Database](https://img.shields.io/badge/Database-Google_Spanner-blue)
![API](https://img.shields.io/badge/API-FastAPI-009688.svg?logo=fastapi)

## 📌 Overview

**Survivor Network** is a graph-based analytics and communication platform for survivor communities, powered by **Google Cloud Spanner** and **Vertex AI (Gemini)**.

This project combines a dynamic React frontend with a robust Python/FastAPI backend to visualize relationships between survivors, skills, and resources. It features an advanced AI-powered chat interface that allows users to query the graph database using natural language, leveraging Hybrid Search (RAG + Keyword).

### 🚀 Key Technologies & Concepts
* **Generative AI & LLMs:** Vertex AI (Gemini 1.5 Pro/Flash) for natural language understanding and function calling.
* **Hybrid Search:** Implementation of semantic (RAG) and keyword-based search to optimize query results.
* **Graph Database:** Google Cloud Spanner to map complex relationships (Nodes and Edges).
* **Backend:** Python, FastAPI, and Pydantic.
* **Frontend:** React, TypeScript, and Zustand for state management.

---

## ⚙️ Prerequisites

- **Python**: 3.11 or higher
- **Node.js**: 18 or higher
- **Google Cloud Platform**:
  - Cloud Spanner Instance
  - Vertex AI API enabled (for AI features)
- **Google Cloud Credentials**: A service account key JSON file.

---

## 🛠️ Backend Setup

1.  **Navigate to the backend directory:**
    ```bash
    cd backend
    ```

2.  **Install dependencies with uv:**
    Make sure you have [uv installed](https://github.com/astral-sh/uv).
    ```bash
    uv sync
    ```

3.  **Configuration:**
    - Create a `.env` file in the `backend` directory (see [Environment Variables](#environment-variables)).
    - Place your Google Cloud service account key (e.g., `spanner-key.json`) in the project root or backend directory and reference it in `.env`.

4.  **Initialize the Database:**
    Run the script to populate Spanner with initial sample data.
    ```bash
    uv run python create_property_graph.py
    ```

5.  **Run the Server:**
    ```bash
    uv run uvicorn main:app --reload
    ```
    The backend API will be available at `http://localhost:8000`.

---

## 💻 Frontend Setup

1.  **Navigate to the frontend directory:**
    ```bash
    cd frontend
    ```

2.  **Install dependencies:**
    ```bash
    npm install
    ```

3.  **Configuration:**
    - No configuration needed! Defaults to connecting to `http://localhost:8000`.

4.  **Run the Development Server:**
    ```bash
    npm run dev
    ```
    The application will be accessible at `http://localhost:5173`.

---

## 🔐 Environment Variables

### Backend (`backend/.env`)

| Variable | Description | Default / Example |
| :--- | :--- | :--- |
| `PROJECT_ID` | GCP Project ID | `your-project-id` |
| `INSTANCE_ID` | Spanner Instance ID | `survivor-instance` |
| `DATABASE_ID` | Spanner Database ID | `survivor-db` |
| `GRAPH_NAME` | Spanner Graph Name | `SurvivorGraph` |
| `GOOGLE_APPLICATION_CREDENTIALS` | Path to service account key | `../spanner-key.json` |
| `LOCATION` | Vertex AI Location | `us-central1` |
| `USE_MEMORY_BANK` | Enable Memory Bank agent | `True` |

> **Note**: The frontend doesn't require a `.env` file. It connects to the backend at `http://localhost:8000` by default. Can be overridden: `VITE_API_URL=... npm run dev`

---

## 📂 Project Structure

```text
survivor-network/
├── backend/            # FastAPI Backend
│   ├── agent/          # AI Agent logic
│   ├── api/            # API Routes
│   ├── models/         # Pydantic Models
│   ├── services/       # Spanner & Graph Services
│   └── main.py         # Application Entrypoint
├── frontend/           # React Frontend
│   ├── src/
│   │   ├── components/ # React Components (Chat, Graph, etc.)
│   │   ├── stores/     # State Management (Zustand)
│   │   └── types/      # TypeScript Definitions
│   └── vite.config.ts  # Vite Configuration
└── spanner-key.json    # GCP Credentials (Do not commit!)
