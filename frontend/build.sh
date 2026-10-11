#!/bin/bash
set -e

echo "=== Step 1: Checking/Installing Flutter SDK ==="
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
fi

export PATH="$PATH:$HOME/flutter/bin"

flutter --version

echo "=== Step 2: Fetching Dependencies ==="
flutter pub get

echo "=== Step 3: Compiling Flutter Web ==="
flutter build web --release --no-tree-shake-icons \
  --dart-define=API_BASE_URL="$API_BASE_URL" \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"

echo "=== Build Finished: Output in build/web ==="
