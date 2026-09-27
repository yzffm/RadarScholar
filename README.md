# RadarScholar

**Scholarship Intelligence Platform**

RadarScholar helps Indonesian university students discover, understand, match, prepare for, and track scholarship applications — all from curated, official sources.

## Architecture

```
Flutter Web (+ Android)
       │
       ▼
    FastAPI
  ┌────┼──────────┐
  ▼    ▼          ▼
 DB  Matching     AI
                  │
            ┌─────┴─────┐
            ▼           ▼
         Gemini       Groq
        primary      fallback
         │
         ▼
PostgreSQL / Supabase
         ▲
         │
  Crawler Pipeline
         │
  GitHub Actions
```

## Tech Stack

| Layer | Technologies |
|-------|-------------|
| Frontend | Flutter, Dart, Material 3, Riverpod, GoRouter, Dio, Freezed |
| Backend | Python, FastAPI, Pydantic, SQLAlchemy 2.x, Alembic, Uvicorn |
| Database | PostgreSQL, Supabase, Supabase Auth |
| AI | Gemini (primary), Groq (fallback) |
| Testing | pytest, flutter_test, Ruff, dart format, flutter analyze |

## Repository Structure

```
RadarScholar/
├── frontend/               # Flutter application
│   └── lib/
│       ├── core/           # Config, theme, responsive utilities
│       ├── models/         # Data/domain models (M)
│       ├── views/          # Screens and pages (V)
│       ├── controllers/    # Riverpod state providers (C)
│       ├── repositories/   # Data access layer
│       ├── services/       # API service (Dio)
│       ├── widgets/        # Reusable UI components
│       ├── routes/         # GoRouter configuration
│       └── main.dart       # Entry point
├── backend/                # FastAPI application
│   ├── app/
│   │   ├── api/            # Health and shared API routes
│   │   ├── core/           # Configuration and settings
│   │   ├── users/          # Profiles and user endpoints
│   │   ├── scholarships/   # Scholarship domain and endpoints
│   │   ├── applications/   # Saved scholarships and tracking
│   │   ├── matching/       # Deterministic matching engine
│   │   ├── crawler/        # Curated source registry and pipeline
│   │   ├── ai/             # AI abstraction and tasks
│   │   ├── auth/           # Supabase identity verification
│   │   └── database/       # SQLAlchemy base/session
│   ├── alembic/            # Database migrations
│   ├── scripts/            # Idempotent seed utilities
│   └── tests/              # Backend tests
├── docs/                   # Documentation
├── Technical Docs.md       # Technical source of truth
├── AGENTS.md               # AI agent instructions
└── README.md               # This file
```

## Local Development Setup

### Prerequisites

- Flutter SDK (3.38+)
- Dart SDK (3.10+)
- Python (3.11+)
- Git

### Frontend

```bash
cd frontend

# Install dependencies
flutter pub get

# Run on web (development)
flutter run -d chrome

# Run analysis
flutter analyze

# Format check
dart format --set-exit-if-changed .

# Run tests
flutter test
```

### Backend

```bash
cd backend

# Create virtual environment
python -m venv venv

# Activate (Windows)
venv\Scripts\activate

# Activate (macOS/Linux)
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
# Or install the package with development tools
# pip install -e ".[dev]"

# Copy environment template
cp .env.example .env
# Edit .env with your values

# Run development server
uvicorn app.main:app --reload --port 8000

# Run tests
pytest

# Run linter
ruff check .
```

### Connecting Frontend to Backend

1. Start the backend: `uvicorn app.main:app --reload --port 8000`
2. Start the frontend: `cd frontend && flutter run -d chrome`
3. The landing page will show backend connection status

The Flutter app connects to `http://localhost:8000` by default. Override with:
```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://your-host:8000
```

Flutter authentication configuration is separate from `backend/.env`. For
local login, pass the public Supabase values at build/run time:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-public-anon-key
```

The discovery page reads from the FastAPI backend, not directly from Supabase.
The backend's `DATABASE_URL` must point to the same database used by the
crawler workflow. A crawler run in GitHub Actions does not populate a local
`backend/radarscholar.db` file.

## Environment Configuration

Copy `backend/.env.example` to `backend/.env` and fill in values:

| Variable | Description | Required For |
|----------|-------------|-------------|
| `DATABASE_URL` | PostgreSQL connection string | M3+ |
| `SUPABASE_URL` | Supabase project URL | M2+ |
| `SUPABASE_ANON_KEY` | Supabase anonymous key | M2+ |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase service role key | M2+ |
| `GEMINI_API_KEY` | Google Gemini API key | M8+ |
| `GROQ_API_KEY` | Groq API key | M8+ |

> ⚠️ **Never commit `.env` files or real credentials.**

## Milestone Roadmap

| Milestone | Description | Status |
|-----------|-------------|--------|
| M0 | Product Contract & Repository Foundation | ✅ |
| M1 | Design System & App Shell | ✅ |
| M2 | Authentication & Profile | ✅ |
| M3 | Scholarship Data Foundation | ✅ |
| M4 | Scholarship Discovery | ✅ |
| M5 | Matching | ✅ |
| M6 | Saved & Application Tracking | ✅ |
| M7 | Curated Crawler | ✅ |
| M8 | AI Intelligence | ✅ |
| M9 | AI Application Assistant | ✅ |
| M10 | Source Monitoring/Admin | 🟨 |
| M11 | Hardening | ⬜ |
| M12 | Deployment/Release | ⬜ |

> ✅ Implemented & test-covered · 🟨 Implemented, test coverage pending · ⬜ Not started


## API Endpoints

### M0

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Backend health check |

### M4 & M5

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/scholarships` | Discover scholarships (paginated, search, filter) |
| GET | `/api/v1/scholarships/{id}` | Get single scholarship detail |
| GET | `/api/v1/scholarships/matched` | Discover scholarships matched against authenticated user's profile |
| GET | `/api/v1/scholarships/{id}/match` | Get match evaluation for a single scholarship against authenticated user's profile |

### M6, M8 & M10

| Method | Path | Description |
|--------|------|-------------|
| GET/POST/PUT | `/api/v1/users/me` | Read, create, or update the authenticated user's profile |
| POST/DELETE | `/api/v1/scholarships/{id}/save` | Save or unsave a scholarship |
| GET | `/api/v1/saved-scholarships` | List saved scholarships |
| GET/POST | `/api/v1/applications` | List or create application trackers |
| GET/PUT/DELETE | `/api/v1/applications/{id}` | Read, update, or delete an application tracker |
| POST/PUT/DELETE | `/api/v1/applications/{id}/tasks` | Manage application checklist tasks |
| GET | `/api/v1/scholarships/{id}/ai-explanation` | Generate deterministic-match explanation with AI assistance |
| POST | `/api/v1/applications/{id}/ai-assistant` | Generate AI application preparation feedback |
| GET | `/api/v1/admin/sources` | List curated sources for admin users |
| POST | `/api/v1/admin/sources/{id}/toggle` | Enable or disable a curated source |
| GET | `/api/v1/admin/crawls` | List crawler run history |

## License

Private — RadarScholar
