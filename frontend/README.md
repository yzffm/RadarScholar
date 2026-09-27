# RadarScholar Frontend

Flutter Web application for RadarScholar, with Android-compatible structure for
future mobile releases.

## Architecture

```text
Views → Riverpod Controllers → Repositories → Dio API Service → FastAPI
```

- `lib/models/`: API and domain models.
- `lib/views/`: pages and presentation widgets.
- `lib/controllers/`: Riverpod state and user interactions.
- `lib/repositories/`: API data access.
- `lib/services/`: Dio and Supabase integration.
- `lib/routes/`: GoRouter configuration.
- `lib/core/`: theme, responsive helpers, and compile-time configuration.

## Setup

From the repository root:

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

The default backend URL is `http://localhost:8000`. Override it for another
environment with:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=https://api.example.com
```

Supabase client configuration uses compile-time values:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-public-anon-key
```

Flutter does not read `backend/.env`. These two `--dart-define` values are
required for email/password and Google authentication. The backend's
`SUPABASE_URL` and the Flutter `SUPABASE_URL` must refer to the same project.

Never put a Supabase service-role key or other privileged credential in Flutter
source or `--dart-define` values.

## Quality Checks

```bash
flutter analyze
dart format --set-exit-if-changed .
flutter test
```

The app must remain responsive on desktop, tablet, and mobile widths. Dynamic
scholarship collections use `ListView.builder` as required by the project
acceptance criteria.
