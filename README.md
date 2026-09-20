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
│   │   ├── api/            # API route handlers
│   │   ├── core/           # Configuration, settings
│   │   ├── models/         # SQLAlchemy models
│   │   ├── schemas/        # Pydantic schemas
│   │   ├── repositories/   # Data access
│   │   └── services/       # Business logic
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
| M1 | Design System & App Shell | 🔄 |
| M2 | Authentication & Profile | ⬜ |
| M3 | Scholarship Data Foundation | ⬜ |
| M4 | Scholarship Discovery | ⬜ |
| M5 | Matching | ⬜ |
| M6 | Saved & Application Tracking | ⬜ |
| M7 | Curated Crawler | ⬜ |
| M8 | AI Intelligence | ⬜ |
| M9 | AI Application Assistant | ⬜ |
| M10 | Source Monitoring/Admin | ⬜ |
| M11 | Hardening | ⬜ |
| M12 | Deployment/Release | ⬜ |


## API Endpoints

### M0

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Backend health check |

## License

Private — RadarScholar
