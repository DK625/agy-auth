# =========================================================
# agi-auth & statusline Installer for Windows PowerShell
# =========================================================

$ErrorActionPreference = "Stop"

$InstallDir = "$env:USERPROFILE\.agi-auth"
$BinDir = "$InstallDir\bin"
$GeminiDir = "$env:USERPROFILE\.gemini"
$Timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$BaseUrl = "https://raw.githubusercontent.com/DK625/agy-auth/main"

Write-Host "==> Installing / Updating agi-auth, agi shortcut and Statusline..." -ForegroundColor Cyan

# Create directories
New-Item -ItemType Directory -Path $BinDir -Force | Out-Null
New-Item -ItemType Directory -Path "$GeminiDir\accounts" -Force | Out-Null
New-Item -ItemType Directory -Path "$env:USERPROFILE\.local\bin" -Force | Out-Null

# 1. Download agi-auth CLI script
Invoke-WebRequest -Uri "$BaseUrl/bin/agi-auth?t=$Timestamp" -Headers @{ "Cache-Control" = "no-cache"; "Pragma" = "no-cache" } -OutFile "$BinDir\agi-auth.py" -UseBasicParsing

# Create .cmd wrapper
$cmdContent = "@echo off`npython `"$BinDir\agi-auth.py`" %*"
Set-Content -Path "$BinDir\agi-auth.cmd" -Value $cmdContent -Encoding ASCII
Set-Content -Path "$env:USERPROFILE\.local\bin\agi-auth.cmd" -Value $cmdContent -Encoding ASCII

# 2. Download Statusline Script & Configuration
$StatuslinePs1Path = "$GeminiDir\statusline.ps1"
$StatuslineJsonPath = "$GeminiDir\statusline.json"
Invoke-WebRequest -Uri "$BaseUrl/statusline/statusline.ps1?t=$Timestamp" -Headers @{ "Cache-Control" = "no-cache"; "Pragma" = "no-cache" } -OutFile $StatuslinePs1Path -UseBasicParsing

if (!(Test-Path $StatuslineJsonPath)) {
    Invoke-WebRequest -Uri "$BaseUrl/statusline/statusline.json?t=$Timestamp" -Headers @{ "Cache-Control" = "no-cache"; "Pragma" = "no-cache" } -OutFile $StatuslineJsonPath -UseBasicParsing
}

# 3. Configure Antigravity CLI Settings (statusLine command)
$settingsPaths = @(
    "$env:USERPROFILE\.gemini\antigravity-cli\settings.json",
    "$env:USERPROFILE\.gemini\settings.json",
    "$env:LOCALAPPDATA\agy\settings.json",
    "$env:APPDATA\agy\settings.json"
)

$statusLineCommand = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$StatuslinePs1Path`""

foreach ($sPath in $settingsPaths) {
    try {
        $sDir = [System.IO.Path]::GetDirectoryName($sPath)
        if (-not (Test-Path $sDir)) {
            New-Item -ItemType Directory -Path $sDir -Force | Out-Null
        }
        
        $settingsObj = $null
        if (Test-Path $sPath) {
            try {
                $content = Get-Content -Path $sPath -Raw -ErrorAction SilentlyContinue
                if (-not [string]::IsNullOrWhiteSpace($content)) {
                    $settingsObj = $content | ConvertFrom-Json
                }
            } catch {}
        }
        
        if ($null -eq $settingsObj) { $settingsObj = [PSCustomObject]@{} }
        
        if ($null -eq $settingsObj.PSObject.Properties["statusLine"]) {
            $settingsObj | Add-Member -MemberType NoteProperty -Name "statusLine" -Value ([PSCustomObject]@{ command = $statusLineCommand }) -Force
        } else {
            $settingsObj.statusLine.command = $statusLineCommand
        }
        
        $jsonOut = $settingsObj | ConvertTo-Json -Depth 5
        Set-Content -Path $sPath -Value $jsonOut -Encoding UTF8
    } catch {}
}

# 4. Append to PowerShell Profile if not present
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
Write-Host "Features Installed:" -ForegroundColor White
Write-Host "  [OK] agi-auth CLI         - Multi-account OAuth manager with real-time health checks" -ForegroundColor Green
Write-Host "  [OK] agi Shortcut         - Fast launcher with --dangerously-skip-permissions" -ForegroundColor Green
Write-Host "  [OK] Antigravity Statusline - Real-time model, branch, remain context & 5h/7d quota bars" -ForegroundColor Green
Write-Host ""
Write-Host "Usage:" -ForegroundColor White
Write-Host "  agi-auth login          - Direct Google OAuth login and auto-save by Email" -ForegroundColor Cyan
Write-Host "  agi-auth list           - List all accounts, Email, Quota (Remain 5h/7d) and Errors" -ForegroundColor Cyan
Write-Host "  agi-auth switch <email> - Switch account (by Number or Email)" -ForegroundColor Cyan
Write-Host "  agi-auth remove <email> - Remove an account" -ForegroundColor Cyan
Write-Host "  agi                     - Launch Antigravity CLI with statusline" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ready to use! Try running: agi-auth list" -ForegroundColor Gray
