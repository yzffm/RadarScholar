# =============================================================================
# RadarScholar - Script Build Flutter Web Release untuk Vercel
# =============================================================================
# Usage:
#   .\scripts\build_web_release.ps1 -ApiBaseUrl "https://radarscholar-api.onrender.com"
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

Set-Location $FrontendDir

# Cek argumen API_BASE_URL
$dartDefines = @()

if ($ApiBaseUrl) {
    if (-not $ApiBaseUrl.StartsWith("https://")) {
        Write-Warning "PERINGATAN: API_BASE_URL harus menggunakan HTTPS untuk mode release!"
    }
    $dartDefines += "--dart-define=API_BASE_URL=$ApiBaseUrl"
    Write-Host "-> Menggunakan API_BASE_URL: $ApiBaseUrl" -ForegroundColor Green
} else {
    Write-Host "-> Peringatan: API_BASE_URL tidak diisi. Pastikan Anda menyertakannya jika backend sudah online." -ForegroundColor Yellow
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
flutter build web --release @dartDefines

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
