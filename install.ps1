# =========================================================
# agi-auth Installer for Windows PowerShell
# =========================================================

$ErrorActionPreference = "Stop"

$InstallDir = "$env:USERPROFILE\.agi-auth"
$BinDir = "$InstallDir\bin"
$RawUrl = "https://raw.githubusercontent.com/DK625/agy-auth/main"

Write-Host "==> Installing agi-auth & agi shortcut for Windows..." -ForegroundColor Cyan

# Create directories
New-Item -ItemType Directory -Path $BinDir -Force | Out-Null
New-Item -ItemType Directory -Path "$env:USERPROFILE\.gemini\accounts" -Force | Out-Null
New-Item -ItemType Directory -Path "$env:USERPROFILE\.local\bin" -Force | Out-Null

# Download script
Invoke-WebRequest -Uri "$RawUrl/bin/agi-auth" -OutFile "$BinDir\agi-auth.py"

# Create .cmd wrapper
$cmdContent = "@echo off`npython `"$BinDir\agi-auth.py`" %*"
Set-Content -Path "$BinDir\agi-auth.cmd" -Value $cmdContent -Encoding ASCII
Set-Content -Path "$env:USERPROFILE\.local\bin\agi-auth.cmd" -Value $cmdContent -Encoding ASCII

# Append to PowerShell Profile
$ProfileSnippet = @"

# --- agi & agi-auth (Antigravity CLI Manager) ---
if (Test-Path "$BinDir") {
    if (`$env:Path -notlike "*$BinDir*") {
        `$env:Path = "$BinDir;`$env:Path"
    }
}
function agi {
    agy --dangerously-skip-permissions @args
}
"@

if (!(Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

$currentProfile = Get-Content -Path $PROFILE -Raw -ErrorAction SilentlyContinue
if ($currentProfile -notmatch "agi-auth") {
    Add-Content -Path $PROFILE -Value $ProfileSnippet
    Write-Host "Added 'agi' and 'agi-auth' to PowerShell `$PROFILE." -ForegroundColor Green
}

Write-Host ""
Write-Host "==> Installation successful!" -ForegroundColor Green
Write-Host ""
Write-Host "Usage:" -ForegroundColor White
Write-Host "  agi-auth login <name>   - Login to a new account & save as <name>" -ForegroundColor Cyan
Write-Host "  agi-auth list           - List all saved accounts" -ForegroundColor Cyan
Write-Host "  agi-auth switch <name>  - Switch to saved account" -ForegroundColor Cyan
Write-Host "  agi-auth remove <name>  - Remove a saved account" -ForegroundColor Cyan
Write-Host "  agi                     - Run agy with --dangerously-skip-permissions" -ForegroundColor Cyan
Write-Host ""
Write-Host "Restart your terminal or run: . `$PROFILE" -ForegroundColor Gray
