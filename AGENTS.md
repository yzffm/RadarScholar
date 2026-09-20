# AGENTS.md — RadarScholar AI Agent Instructions

> This file is the engineering constitution for AI Agents working on RadarScholar.
> `Technical Docs.md` is the human-facing technical source of truth.
> The human project owner has final authority over material product and architecture decisions.

For complete agent instructions, see:
- [`.agents/rules/agents.md`](.agents/rules/agents.md) — Core agent rules (§1–§23)
- [`.agents/rules/agents2.md`](.agents/rules/agents2.md) — Extended rules (§24–§30)

## Quick Reference

### Mission
Build RadarScholar — a Scholarship Intelligence Platform — correctly, incrementally, and transparently.

### Current Stack
| Layer | Technologies |
|-------|-------------|
| Frontend | Flutter Web/Dart, Material 3, Riverpod, GoRouter, Dio, Freezed, json_serializable |
| Backend | Python, FastAPI, Pydantic, SQLAlchemy 2.x, Alembic, Uvicorn |
| Database | PostgreSQL, Supabase, Supabase Auth |
| AI | Gemini (primary), Groq (fallback), Ollama (optional/local) |
| Crawler | httpx, BeautifulSoup4, lxml, Playwright, PyMuPDF, GitHub Actions |
| Testing | pytest, flutter_test, integration_test, Ruff, dart format, flutter analyze |

### Milestones
```
M0  Foundation          ← current
M1  Design System & App Shell
M2  Authentication & Profile
M3  Scholarship Data Foundation
M4  Scholarship Discovery
M5  Matching
M6  Saved & Application Tracking
M7  Curated Crawler
M8  AI Intelligence
M9  AI Application Assistant
M10 Source Monitoring/Admin
M11 Hardening
M12 Deployment/Release
```

### Key Rules
1. **Never fabricate** scholarship facts, user achievements, or data
2. **Never store** plaintext passwords or commit secrets
3. **Never bypass** anti-bot/access controls in crawling
4. **AI assists** but does not decide objective eligibility
5. **Milestone discipline** — don't implement future features
6. **Human approval** required for material architecture changes

### CPMK Requirements
1. API Integration (Flutter → FastAPI)
2. Responsive UI (desktop/tablet/mobile)
3. GitHub repository
4. MVC architecture
5. Mobile compilation (Android)
6. ListView.builder for dynamic collections
