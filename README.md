# Automated SEO Insights

An AI-powered SEO analysis and keyword research tool with a React frontend and Node.js/Express backend.

## Features

- **SEO Audit** — Rule-based analysis of title tags, meta descriptions, headings, images, Open Graph, and word count, with an AI-enhanced scoring layer via IBM Watsonx Orchestrate
- **Deep Crawl** — BFS crawler that follows internal links up to a configurable depth, auditing every page and producing an aggregate report
- **Keyword Research** — Semantic keyword suggestion powered by `all-MiniLM-L6-v2` sentence transformers; finds and analyses real competitors via live web search
- **Dashboard** — Overview metrics, recent keyword inputs, and audit history
- **User Accounts** — JWT-based auth, profile settings, and password management
- **Reports** — Dynamically generated from saved audits (single-page and deep crawl)

## Tech Stack

| Layer    | Tech |
|----------|------|
| Frontend | React 18, Create React App |
| Backend  | Node.js, Express 4, Mongoose 7 |
| Database | MongoDB |
| AI       | IBM Watsonx Orchestrate (optional), `@xenova/transformers` |
| Auth     | bcrypt, jsonwebtoken |

## Project Structure

```
Aiseo-main/
├── server.js                  # Express server (routes, models, middleware)
├── services/
│   ├── agentService.js        # IBM Watsonx Orchestrate client
│   ├── seoAuditService.js     # SEO audit engine + deep crawler
│   ├── keywordResearchService.js  # Semantic keyword research
│   └── webSearchService.js    # Live competitor scraping (DuckDuckGo/Google)
├── src/
│   ├── App.js                 # Root React component
│   ├── components/            # UI components (Dashboard, SEOAudit, Settings, etc.)
│   └── utils/                 # Helpers (notifications)
├── public/
│   └── index.html
└── package.json
```

## Getting Started

### Prerequisites

- Node.js >= 18
- MongoDB running locally or a connection string

### Install & Run

```bash
cd Aiseo-main
npm install
```

Create a `.env` file in `Aiseo-main/`:

```env
PORT=5000
MONGO_URI=mongodb://127.0.0.1:27017/seo_tool
JWT_SECRET=your-random-secret

# Optional — enables AI-enhanced audits via IBM Watsonx
WATSONX_API_KEY=
WATSONX_INSTANCE_SECRET=
WATSONX_SERVICE_URL=https://eu-gb.watson-orchestrate.cloud.ibm.com
WATSONX_AGENT_ID=
WATSONX_AGENT_ENV_ID=
```

Start the backend:

```bash
npm run server
```

In a second terminal, start the frontend:

```bash
npm start
```

The React app runs on `http://localhost:3000` and proxies API calls to `http://localhost:5000`.

> **First-run note:** The keyword research feature downloads the MiniLM-L6-v2 model (~20 MB). Subsequent runs use the cache.

## API Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/api/auth/register` | No | Create account |
| POST | `/api/auth/login` | No | Login |
| GET/PUT | `/api/user/me` | Yes | Get or update profile |
| POST | `/api/user/change-password` | Yes | Change password |
| POST | `/api/seo-audit` | Yes | Run single-page or deep crawl audit |
| GET | `/api/seo-audit` | Yes | Audit history |
| GET | `/api/seo-audit/:id` | Yes | Specific audit |
| POST | `/api/keywords/research` | Yes | Keyword research + competitor analysis |
| GET | `/api/dashboard/overview` | Yes | Dashboard metrics |
| GET | `/api/dashboard/keywords` | Yes | Recent keyword inputs |
| GET | `/api/reports` | Yes | Reports list |
| GET | `/api/watsonx/token` | Yes | Watsonx auth token (if configured) |

## License

MIT
