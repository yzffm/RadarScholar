# =============================================================================
# RadarScholar - Script Build Flutter Web Release untuk Vercel
# =============================================================================
# Usage:
#   .\scripts\build_web_release.ps1 -ApiBaseUrl "https://username-radarscholar-api.hf.space"
# =============================================================================

param (
    [Parameter(Mandatory=$false)]
    [string]$ApiBaseUrl = "",

    [Parameter(Mandatory=$false)]
    [string]$SupabaseUrl = "",

    [Parameter(Mandatory=$false)]
    [string]$SupabaseAnonKey = ""
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " RadarScholar Flutter Web Release Builder " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Pindah ke direktori frontend
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$RootDir = Split-Path -Parent $ScriptDir
$FrontendDir = Join-Path $RootDir "frontend"

# Auto-load Supabase credentials from backend/.env if not provided
$BackendEnvPath = Join-Path $RootDir "backend\.env"
if (Test-Path $BackendEnvPath) {
    Get-Content $BackendEnvPath | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith("#")) {
            if ($line -match "^SUPABASE_URL=(.*)$" -and -not $SupabaseUrl) {
                $SupabaseUrl = $matches[1].Trim()
            }
            if ($line -match "^SUPABASE_ANON_KEY=(.*)$" -and -not $SupabaseAnonKey) {
                $SupabaseAnonKey = $matches[1].Trim()
            }
        }
    }
}

# Default API URL to live HF Space if not specified
if (-not $ApiBaseUrl) {
    $ApiBaseUrl = "https://yzffm-radarscholar-api.hf.space"
}

Set-Location $FrontendDir

# Cek argumen API_BASE_URL
$dartDefines = @()

if ($ApiBaseUrl) {
    if (-not $ApiBaseUrl.StartsWith("https://")) {
        Write-Warning "PERINGATAN: API_BASE_URL harus menggunakan HTTPS untuk mode release!"
    }
    $dartDefines += "--dart-define=API_BASE_URL=$ApiBaseUrl"
    Write-Host "-> Menggunakan API_BASE_URL: $ApiBaseUrl" -ForegroundColor Green
}

if ($SupabaseUrl) {
    $dartDefines += "--dart-define=SUPABASE_URL=$SupabaseUrl"
}

if ($SupabaseAnonKey) {
    $dartDefines += "--dart-define=SUPABASE_ANON_KEY=$SupabaseAnonKey"
}

Write-Host "-> Menjalankan flutter pub get..." -ForegroundColor Gray
flutter pub get

Write-Host "-> Mengompilasi Flutter Web Release..." -ForegroundColor Gray
flutter build web --release --no-tree-shake-icons @dartDefines

if ($LASTEXITCODE -ne 0) {
    Write-Error "Gagal mengompilasi Flutter Web! Periksa pesan error di atas."
    exit 1
}

# Salin vercel.json ke build/web
$VercelJsonSource = Join-Path $FrontendDir "vercel.json"
$VercelJsonDest = Join-Path $FrontendDir "build\web\vercel.json"

if (Test-Path $VercelJsonSource) {
    Copy-Item $VercelJsonSource -Destination $VercelJsonDest -Force
    Write-Host "-> vercel.json disalin ke build/web/" -ForegroundColor Green
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host " BUILD SELESAI! Folder: frontend/build/web " -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Untuk mendeploy ke Vercel sekarang, jalankan perintah:" -ForegroundColor Yellow
Write-Host "  cd frontend\build\web" -ForegroundColor White
Write-Host "  npx vercel --prod" -ForegroundColor White
Write-Host ""
