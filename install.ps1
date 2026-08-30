# =========================================================
# agi-auth Installer for Windows PowerShell
# =========================================================

$ErrorActionPreference = "Stop"

$InstallDir = "$env:USERPROFILE\.agi-auth"
$BinDir = "$InstallDir\bin"
$Timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$RawUrl = "https://raw.githubusercontent.com/DK625/agy-auth/main/bin/agi-auth?t=$Timestamp"

Write-Host "==> Installing / Updating agi-auth & agi shortcut for Windows..." -ForegroundColor Cyan

# Create directories
New-Item -ItemType Directory -Path $BinDir -Force | Out-Null
New-Item -ItemType Directory -Path "$env:USERPROFILE\.gemini\accounts" -Force | Out-Null
New-Item -ItemType Directory -Path "$env:USERPROFILE\.local\bin" -Force | Out-Null

# Download latest script (bypassing CDN cache)
Invoke-WebRequest -Uri $RawUrl -Headers @{ "Cache-Control" = "no-cache"; "Pragma" = "no-cache" } -OutFile "$BinDir\agi-auth.py" -UseBasicParsing

# Create .cmd wrapper
$cmdContent = "@echo off`npython `"$BinDir\agi-auth.py`" %*"
Set-Content -Path "$BinDir\agi-auth.cmd" -Value $cmdContent -Encoding ASCII
Set-Content -Path "$env:USERPROFILE\.local\bin\agi-auth.cmd" -Value $cmdContent -Encoding ASCII

# Append to PowerShell Profile if not present
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
Write-Host "==> Installation / Update successful!" -ForegroundColor Green
Write-Host ""
Write-Host "Usage:" -ForegroundColor White
Write-Host "  agi-auth login          - Direct Google OAuth login & auto-save by Email" -ForegroundColor Cyan
Write-Host "  agi-auth list           - List all saved accounts, Email & Quota (5h/weekly)" -ForegroundColor Cyan
Write-Host "  agi-auth switch <email> - Switch to saved account (by Email or Alias)" -ForegroundColor Cyan
Write-Host "  agi-auth remove <email> - Remove a saved account" -ForegroundColor Cyan
Write-Host "  agi                     - Run agy with --dangerously-skip-permissions" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ready to use! Try running: agi-auth list" -ForegroundColor Gray
