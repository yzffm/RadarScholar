# Local Development Setup

## Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| Flutter SDK | 3.38+ | [Install Flutter](https://docs.flutter.dev/get-started/install) |
| Dart SDK | 3.10+ | Included with Flutter |
| Python | 3.11+ | [Download Python](https://www.python.org/downloads/) |
| Git | 2.x+ | [Download Git](https://git-scm.com/) |

## Quick Start

### 1. Clone the repository

```bash
git clone <repository-url>
cd RadarScholar
```

### 2. Backend Setup

```bash
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows (PowerShell):
venv\Scripts\Activate.ps1
# Windows (cmd):
venv\Scripts\activate.bat
# macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
# Alternatively, install the package and development tools:
# pip install -e ".[dev]"

# Copy environment template
cp .env.example .env
# Edit .env with your values (see Environment Variables below)

# Run the development server
uvicorn app.main:app --reload --port 8000
```

The API should now be running at `http://localhost:8000`.
Verify liveness: `http://localhost:8000/health`
Verify database readiness: `http://localhost:8000/health/ready`

### 3. Frontend Setup

```bash
cd frontend

# Install dependencies
flutter pub get

# Run on Chrome (web)
flutter run -d chrome

# Or run on connected Android device
flutter run -d <device-id>
```

## Environment Variables

All environment variables are documented in `backend/.env.example`.

**Important:** Never commit `.env` files containing real credentials.

| Variable | When Needed | Description |
|----------|-------------|-------------|
| `DATABASE_URL` | M3+ | PostgreSQL connection string |
| `SUPABASE_URL` | M2+ | Supabase project URL |
| `SUPABASE_ANON_KEY` | M2+ | Supabase anonymous/public key |
| `SUPABASE_SERVICE_ROLE_KEY` | M2+ | Supabase service role key (backend only) |
| `GEMINI_API_KEY` | M8+ | Google Gemini API key |
| `GROQ_API_KEY` | M8+ | Groq API key (fallback AI) |

## Running Tests

### Backend
```bash
cd backend
pytest                          # Run all tests
ruff check .                    # Lint
```

### Frontend
```bash
cd frontend
flutter test                    # Run all tests
flutter analyze                 # Static analysis
dart format --set-exit-if-changed .  # Format check
```

## Common Issues

### Flutter: "Backend unavailable" on landing page
The backend must be running. Start it with:
```bash
cd backend && uvicorn app.main:app --reload --port 8000
```

### Python version mismatch
Ensure `python --version` shows 3.11+. If multiple Python versions are installed, use `python3` or the full path to the correct interpreter.

### CORS errors in browser console
The backend allows configured origins from `CORS_ORIGINS`. In development,
localhost origins are supported when `DEBUG=true`. In production, configure
explicit HTTPS origins and do not rely on the localhost defaults.

### Seed baseline scholarship data
After applying migrations, run the idempotent seed script from `backend/`:
```bash
python scripts/seed_scholarships.py
```
Running it more than once updates the same baseline records instead of creating
duplicates. Seed records are marked with `data_origin=SEED` and are not treated
as live-verified until the curated crawler confirms them.
