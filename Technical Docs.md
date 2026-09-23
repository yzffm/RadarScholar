# RadarScholar — Technical Documentation

> Human-facing technical source of truth for the RadarScholar team.
> Primary platform: Flutter Web. Future platforms: Android/iOS.
> Material deviations require the Architecture Change Proposal process.

## 1. Project Identity

**Name:** RadarScholar

**Tagline:** Not final. Do not hard-code a tagline until approved.

RadarScholar is a Scholarship Intelligence Platform that helps users:
1. discover scholarship opportunities from curated official sources;
2. understand requirements and benefits;
3. identify opportunities relevant to their profile;
4. understand why an opportunity is relevant;
5. prepare and track applications;
6. use AI as an assistant for scholarship and application preparation.

The MVP focuses on Indonesian students while keeping the architecture extensible for future users such as fresh graduates.

## 2. Product Principles

### Reliability over cleverness
Prefer trustworthy, traceable information over sophisticated but uncertain automation.

### Official source as factual authority
Official scholarship-provider pages are the source of truth. RadarScholar may normalize/summarize information but must preserve source attribution and official URLs.

### Deterministic eligibility first
Objective requirements such as GPA, semester, degree, nationality, major, age, or explicit university requirements should be evaluated deterministically whenever possible.

### AI as assistant
AI may explain, interpret, recommend, assist with writing, and simulate interviews. It must not silently become the authority for objective eligibility.

### Graceful degradation
Core discovery, filtering, details, matching, saving, and application tracking must continue when AI providers are unavailable.

### Privacy by design
Collect only necessary information. Never store plaintext passwords. Never expose privileged credentials to clients. Minimize personal data sent to AI providers.

### Curated crawling
MVP crawling is limited to manually approved scholarship sources.

### Human approval for material changes
Agents may propose improvements, but material product/architecture changes require human approval.

## 3. MVP Scope

Core capabilities:
- Supabase authentication;
- user profile;
- scholarship discovery/search/filter;
- scholarship details;
- curated crawling;
- scholarship normalization;
- requirement representation;
- deterministic relevance/eligibility engine;
- qualitative relevance explanations;
- saved scholarships;
- deadlines and application tracking;
- application checklist;
- AI scholarship explanation/recommendation;
- AI-assisted CV, motivation-letter, essay, and interview preparation;
- source monitoring/admin capabilities in later milestones.

Explicitly out of scope unless approved:
- payment systems;
- social network/community feed;
- in-app scholarship submission;
- internet-wide autonomous crawling;
- anti-bot/access-control bypassing;
- custom password storage;
- ML training as a core requirement;
- microservices;
- Kubernetes;
- Redis;
- Kafka;
- vector databases;
- local LLM as a required production dependency.

## 4. User Profile

Profile data should support matching while following data minimization.

### Academic
- university;
- faculty;
- major;
- degree level;
- semester;
- GPA.

### Experience
- organizations;
- achievements;
- competitions;
- volunteering;
- internships;
- certifications;
- skills.

### Interests
- career interests;
- fields of interest;
- goals.

Personal information should be optional unless required. Do not collect unnecessary sensitive information.

## 5. Authentication and Privacy

Use **Supabase Auth**.

RadarScholar application tables must not store passwords or password hashes.

Conceptually:

```text
Flutter
  ↓
Supabase Auth
  ↓
authenticated identity
  ↓
RadarScholar profile/application data
```

Never expose:
- Supabase service-role key;
- Gemini secret credentials;
- Groq secret credentials;
- backend administrative credentials

to Flutter/client code.

Backend authorization must derive identity from verified authentication context and enforce ownership.

For Indonesian deployment/research, review **UU No. 27 Tahun 2022 tentang Pelindungan Data Pribadi (UU PDP)** with appropriate institutional guidance. This document is an engineering guide, not legal advice.

## 6. Scholarship Data Model

Initial domain entities:

```text
UserProfile
ScholarshipSource
Scholarship
ScholarshipRequirement
ScholarshipBenefit
ScholarshipSnapshot
CrawlRun
SavedScholarship
Application
ApplicationTask
AIRequestLog
```

The exact schema may be refined during M3.

Important principles:
- foreign keys;
- appropriate unique constraints;
- useful indexes;
- timestamps;
- source attribution;
- migration-based schema changes;
- explicit handling of incomplete information.

Requirement states may include:

```text
MATCH
NOT_MATCH
UNKNOWN
NOT_APPLICABLE
NEEDS_VERIFICATION
```

## 7. Scholarship Discovery

Users should be able to:
- browse scholarships;
- search;
- filter;
- sort where useful;
- view details;
- open official source/application pages.

Details may include:
- provider;
- title;
- summary;
- benefits;
- eligibility;
- application period/deadline;
- application method;
- official URLs;
- crawl/verification metadata.

If the official source does not specify a requirement, display it as unknown/not specified rather than guessing.

## 8. Matching Engine

The system should answer:

> “Beasiswa mana yang mungkin relevan dengan profil saya?”

It should not pretend to calculate exact acceptance probability.

Use qualitative language such as:
- Sangat relevan;
- Relevan;
- Mungkin relevan;
- Perlu dicek;
- Belum cukup informasi.

Do not expose overly precise numeric match scores.

Example explanation:

```text
Kamu cocok dengan beasiswa ini karena:
- jenjangmu sesuai;
- bidang studimu sesuai;
- IPK memenuhi batas minimum yang diketahui.

Perlu diperiksa:
- persyaratan pengalaman organisasi belum dapat dipastikan.
```

Every explanation should be traceable to structured requirements and/or official source information.

## 9. Crawler Architecture

MVP uses a **curated source registry**. Examples may include BCA, Djarum, Bank Indonesia, Astra, LPDP, and other sources approved by the team.

Source metadata may include:

```text
provider
source_url
crawl_method
robots_status
tos_reviewed
crawl_allowed
last_checked
active
```

Prefer source-specific adapters rather than one fragile universal scraper.

Potential tools:
- httpx;
- BeautifulSoup4;
- lxml;
- Playwright for JavaScript-heavy pages;
- PyMuPDF for relevant PDFs.

Crawler requirements:
- conservative rate limiting;
- bounded retries;
- limited concurrency;
- source/timestamp recording;
- duplicate detection;
- failure logging;
- disable-able sources.

Never bypass:
- CAPTCHA;
- authentication;
- Cloudflare/anti-bot controls;
- rate limits;
- technical access restrictions.

Review applicable robots.txt, Terms of Service, copyright/reuse, privacy, and access restrictions before adding sources.

Prefer structured metadata, attribution, and official URLs over copying entire articles.

## 10. Backend

### Stack
- Python;
- FastAPI;
- Pydantic;
- SQLAlchemy 2.x;
- Alembic;
- Uvicorn.

Suggested structure:

```text
backend/
└── app/
    ├── api/
    ├── auth/
    ├── users/
    ├── scholarships/
    ├── matching/
    ├── applications/
    ├── crawler/
    ├── ai/
    ├── database/
    ├── core/
    └── tests/
```

Use REST conventions, validation, authorization, meaningful HTTP status codes, structured errors, and pagination where needed.

## 11. Frontend

### Stack
- Flutter Web / Dart;
- Material 3;
- Riverpod;
- GoRouter;
- Dio;
- Freezed;
- json_serializable.

Suggested architecture:

```text
Presentation
    ↓
State / Controller
    ↓
Repository / Service
    ↓
API
```

Avoid browser-only coupling in business logic so Android/iOS can be added later.

Suggested routes:

```text
/
├── landing
├── auth
├── onboarding/profile
├── scholarships
├── scholarships/:id
├── saved
├── applications
├── application/:id
└── profile
```

## 12. AI Architecture

```text
AI Abstraction Layer
        │
        ├── Gemini — primary
        │
        └── Groq — fallback
```

Ollama is optional for local experimentation only, not a required production dependency.

Provider abstraction should isolate vendor-specific logic:

```text
AIProvider
├── generate()
├── generate_structured()
└── health_check()
```

Suggested organization:

```text
backend/app/ai/
├── base.py
├── service.py
├── providers/
│   ├── gemini.py
│   ├── groq.py
│   └── ollama.py
├── tasks/
│   ├── extraction.py
│   ├── explanation.py
│   ├── recommendation.py
│   ├── writing.py
│   └── interview.py
└── prompts/
```

Gemini is primary. Groq is fallback for appropriate transient failures such as timeout, rate limit, provider outage, or invalid provider response.

Do not call both providers for every request.

AI must not invent:
- scholarship requirements;
- achievements;
- education;
- experience;
- awards;
- skills;
- personal history.

When AI discusses scholarship facts, provide source-backed structured context and communicate uncertainty.

## 13. Application Assistant

Later AI milestones may provide:
- CV improvement;
- motivation letter assistance;
- essay brainstorming/feedback;
- interview practice;
- contextual recommendations.

The architecture should be ready for these capabilities, but implementation should remain milestone-based.

## 14. Error Handling

External systems can fail:
- Supabase;
- websites;
- crawler parsers;
- AI providers;
- network;
- database;
- API.

Distinguish:
- empty data;
- unavailable data;
- failed refresh;
- authorization failure.

Do not hide meaningful errors or retry indefinitely.

## 15. Testing

### Backend
- pytest;
- matching-rule tests;
- API validation;
- authorization;
- crawler parsing;
- duplicate handling;
- error paths.

### Frontend
- flutter_test;
- integration_test;
- authentication;
- navigation;
- discovery;
- saving;
- application tracking;
- critical error states.

### Quality
- Ruff;
- Black;
- dart format;
- flutter analyze.

Crawler parsers should use representative HTML/PDF fixtures where possible.

## 16. Development and Infrastructure

Docker is **not required**.

Prefer:
- Python venv;
- project dependency files;
- Flutter SDK;
- Git;
- GitHub;
- Supabase hosted services;
- environment variables;
- GitHub Actions.

Maintain `.env.example`. Never commit `.env` or secrets.

The project follows a free-tier-first / zero-budget-friendly MVP philosophy. Paid dependencies require human approval.

## 17. Git Workflow

Recommended branches:

```text
main
├── feature/...
├── fix/...
└── chore/...
```

Commit prefixes:

```text
feat:
fix:
refactor:
test:
docs:
chore:
```

Keep commits focused and create recognizable milestone checkpoints.

## 18. Milestone Roadmap

### M0 — Product Contract & Repository Foundation
Deliver:
- repositories;
- docs;
- initial Flutter/FastAPI structure;
- environment strategy;
- basic CI.

Acceptance:
- frontend/backend start;
- no secrets committed;
- quality commands work.

### M1 — Design System & Application Shell
Deliver:
- Material 3 theme;
- typography/spacing;
- responsive shell;
- navigation;
- landing page;
- loading/empty/error states;
- explicit Model/View/Controller conventions.

Academic evidence: CPMK 2 (Responsive), CPMK 4 (MVC).

Review:
- desktop;
- responsive behavior;
- visual hierarchy;
- accessibility basics.

### M2 — Authentication & User Profile
Deliver:
- Supabase Auth;
- registration/login/logout;
- password recovery;
- profile;
- protected routes.

Security review:
- no RadarScholar password storage;
- no service-role secret in client;
- ownership enforcement.

### M3 — Scholarship Data Foundation
Deliver:
- database schema;
- source registry;
- requirements/benefits;
- deadlines;
- source URLs;
- verification metadata;
- migrations;
- sample data.

Review:
- incomplete requirements;
- changing deadlines;
- multiple requirements/benefits;
- attribution.

### M4 — Scholarship Discovery
Deliver:
- listing;
- search;
- filters;
- detail page;
- official links;
- loading/empty/error states;
- real Flutter → FastAPI API integration;
- dynamic scholarship collection using `ListView.builder`.

Academic evidence: CPMK 1 (API Integration), CPMK 6 (`ListView.builder`).

Review:
- useful discovery experience;
- no raw-database feel.

### M5 — Deterministic Matching & Relevance
Deliver:
- rule representation;
- matching engine;
- criterion states;
- qualitative relevance;
- explainability.

Review edge cases:
- GPA below requirement;
- missing GPA;
- unspecified major;
- unspecified semester;
- ambiguous requirements.

### M6 — Saved Scholarships & Application Tracker
Deliver:
- save/unsave;
- applications;
- deadlines;
- statuses;
- checklist/tasks;
- progress.

Review flow:
```text
Discover → Save → Start Application → Prepare → Track Deadline
```

### M7 — Curated Crawler Pipeline
Deliver:
- source registry implementation;
- source-specific crawlers;
- parsing;
- normalization;
- duplicate handling;
- logs;
- failure handling;
- scheduled GitHub Actions.

Review crawler output against official sources.

### M8 — AI Intelligence Layer
Deliver:
- provider abstraction;
- Gemini;
- Groq fallback;
- error handling;
- scholarship explanation;
- recommendation assistance;
- structured output validation.

Review:
- grounding;
- hallucination;
- uncertainty;
- privacy;
- fallback.

### M9 — AI Application Assistant
Deliver:
- CV improvement;
- motivation letter;
- essay support;
- interview practice.

Review:
- no fabricated user facts;
- contextual scholarship data;
- no official-decision claims.

### M10 — Source Monitoring / Admin Foundation
Potentially deliver:
- source status;
- crawl history;
- failed crawl visibility;
- source enable/disable;
- verification status.

Dashboard UI may remain simple initially.

### M11 — Security, Testing & Hardening
Deliver:
- expanded tests;
- authorization review;
- validation;
- secret audit;
- crawler robustness;
- AI failure handling;
- accessibility;
- responsive/performance review.

### M12 — Deployment & Release
Deliver:
- production frontend/backend;
- production Supabase configuration;
- scheduled crawler;
- CI;
- release documentation;
- GitHub repository finalization;
- Android build/run verification;
- final CPMK evidence checklist.

Academic evidence: CPMK 1, 2, 3, 4, 5, and 6.

End-to-end demonstration:
```text
User
 ↓
Profile
 ↓
Scholarship discovery
 ↓
Matching
 ↓
Save
 ↓
Application tracking
 ↓
AI assistance
 ↓
Official application
```

## 19. API Endpoints

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

## 20. Course Mapping

| Component | Relevant Course Area | Evidence |
|---|---|---|
| PostgreSQL schema | Basis Data | ERD, normalization, constraints, queries |
| Supabase/Auth | Security/Web | authentication, authorization |
| FastAPI REST API | Web Programming | HTTP, endpoints, validation |
| Flutter | PBP/UI | responsive UI, state management |
| Crawler | Networking/Distributed Systems | HTTP, scheduling, external systems |
| Matching | AI/Algorithms | deterministic reasoning |
| AI layer | Artificial Intelligence | LLM integration, prompting |
| Data normalization | Data Processing | extraction/normalization |
| Testing | Software Engineering | unit/integration tests |
| GitHub Actions | DevOps | CI/scheduled jobs |
| Security | Security | secrets, auth, access control |
| UX | UI/UX | usability, information architecture |

Adjust course labels to the official curriculum if needed.

## 23. Academic Requirements & CPMK Traceability

RadarScholar must explicitly satisfy these six course assessment requirements (CPMK).

### CPMK 1 — Integrasi API
The Flutter application must consume real FastAPI REST endpoints. Core flows must not rely on hard-coded data.

```text
Flutter Web/Mobile → FastAPI REST API → PostgreSQL/Supabase
                                   ├── Gemini API
                                   └── Groq API
```

Evidence:
- live API request/response;
- loading, success, empty, and error states;
- real scholarship data retrieved through the API.

### CPMK 2 — Responsive
Core screens must work on desktop, tablet, and mobile viewports. Use Flutter responsive/adaptive techniques such as `LayoutBuilder`, `Flexible`, and `Expanded`. Do not merely scale the desktop UI.

### CPMK 3 — Upload / Repository on GitHub
The complete project must be maintained in GitHub with source code, meaningful commit history, README/setup instructions, `.gitignore`, environment-variable documentation, and no committed secrets.

### CPMK 4 — MVC
The Flutter architecture must visibly demonstrate Model–View–Controller while retaining Riverpod.

```text
Model       → data/domain representation
View        → Flutter screens/widgets
Controller  → Riverpod state + user-flow coordination
                 ↓
             Repository
                 ↓
              REST API
```

Substantial API/business logic should not live directly in widgets.

### CPMK 5 — Compile to Mobile
The project starts as Flutter Web but must remain mobile-ready and be verified on Android before release. Avoid unnecessary web-only dependencies.

### CPMK 6 — ListView.builder
Dynamic scholarship collections must explicitly use `ListView.builder`, with Scholarship Discovery as the primary demonstration.

```dart
ListView.builder(
  itemCount: scholarships.length,
  itemBuilder: (context, index) {
    return ScholarshipCard(scholarship: scholarships[index]);
  },
);
```

Other suitable uses include Saved Scholarships, Applications, and Application Tasks.

### CPMK Traceability Matrix

| CPMK | RadarScholar Feature | Technology | Milestone | Evidence |
|---|---|---|---|---|
| 1. API Integration | Profile/scholarship/application API | Flutter + FastAPI | M2–M6 | Live API flow |
| 2. Responsive | Dashboard/discovery/detail | Flutter | M1–M4 | Desktop/tablet/mobile |
| 3. GitHub | Repository + Git workflow | Git/GitHub | M0–M12 | Repo + commits + README |
| 4. MVC | Scholarship discovery architecture | Flutter + Riverpod | M1–M5 | Model/View/Controller |
| 5. Mobile Compile | Android build/run | Flutter | M11–M12 | Android demonstration |
| 6. ListView.builder | Scholarship lists | Flutter | M4 | `ListView.builder` |

### Final Academic Evidence Checklist

```text
[ ] Real API integration demonstrated
[ ] Responsive desktop/tablet/mobile behavior
[ ] GitHub repository ready
[ ] MVC responsibilities identifiable
[ ] Android build/run verified
[ ] ListView.builder demonstrated
```

### Recommended Final Demo

```text
Open Web
  ↓
Show responsive UI
  ↓
Login
  ↓
Fetch profile through API
  ↓
Open Scholarship Discovery
  ↓
Demonstrate ListView.builder
  ↓
Open scholarship detail from API
  ↓
Show matching
  ↓
Save scholarship
  ↓
Show MVC structure
  ↓
Show GitHub repository
  ↓
Build/run on Android
```

## 20. Architecture Change Proposal

Material changes require:

```text
ARCHITECTURE CHANGE PROPOSAL

Current approach:
...

Proposed approach:
...

Reason:
...

Benefits:
...

Trade-offs:
...

Risks:
...

Affected components:
...

Affected milestones:
...

Why the current approach is insufficient:
...

Approval required: YES
```

No material change should be implemented before approval.

## 21. Review Protocol

At each milestone:
1. run automated tests;
2. run static analysis;
3. review database/API changes;
4. launch the application;
5. inspect UI manually;
6. verify acceptance criteria;
7. record issues;
8. create Git checkpoint;
9. explicitly approve continuation.

## 22. Final Engineering Direction

Use a **modular monolith plus a separate scheduled crawler pipeline**.

```text
Flutter Client
      │
      ▼
   FastAPI
 ┌────┼─────────┐
 ▼    ▼         ▼
DB  Matching    AI
               │
          ┌────┴────┐
          ▼         ▼
       Gemini      Groq
      primary     fallback
      │
      ▼
PostgreSQL / Supabase
      ▲
      │
Crawler Pipeline
      │
GitHub Actions
```

Keep the system understandable, secure, reliable, demonstrable, and extensible rather than unnecessarily complex.
