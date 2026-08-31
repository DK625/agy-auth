# =========================================================
# agi-auth & statusline Installer for Windows PowerShell
# =========================================================

$ErrorActionPreference = "Stop"

$InstallDir = "$env:USERPROFILE\.agi-auth"
$BinDir = "$InstallDir\bin"
$GeminiDir = "$env:USERPROFILE\.gemini"
$Timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$BaseUrl = "https://raw.githubusercontent.com/DK625/agy-auth/refs/heads/main"

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
$StatuslinePyPath = "$GeminiDir\statusline.py"
$StatuslineJsonPath = "$GeminiDir\statusline.json"
Invoke-WebRequest -Uri "$BaseUrl/statusline/statusline.py?t=$Timestamp" -Headers @{ "Cache-Control" = "no-cache"; "Pragma" = "no-cache" } -OutFile $StatuslinePyPath -UseBasicParsing

if (!(Test-Path $StatuslineJsonPath)) {
    Invoke-WebRequest -Uri "$BaseUrl/statusline/statusline.json?t=$Timestamp" -Headers @{ "Cache-Control" = "no-cache"; "Pragma" = "no-cache" } -OutFile $StatuslineJsonPath -UseBasicParsing
}

# 3. Download Lifecycle Hooks & Notification Script
$ConfigDir = "$GeminiDir\config"
New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null

$NotifyPyPath = "$GeminiDir\notify.py"
$HooksJsonPath = "$ConfigDir\hooks.json"
$NotifyJsonPath = "$GeminiDir\notify.json"

Invoke-WebRequest -Uri "$BaseUrl/hooks/notify.py?t=$Timestamp" -Headers @{ "Cache-Control" = "no-cache"; "Pragma" = "no-cache" } -OutFile $NotifyPyPath -UseBasicParsing
Invoke-WebRequest -Uri "$BaseUrl/hooks/hooks.json?t=$Timestamp" -Headers @{ "Cache-Control" = "no-cache"; "Pragma" = "no-cache" } -OutFile $HooksJsonPath -UseBasicParsing

# Normalize hooks.json for Windows cmd execution
if (Test-Path $HooksJsonPath) {
    $hooksContent = Get-Content -Path $HooksJsonPath -Raw
    $hooksContent = $hooksContent -replace '~/\.gemini/notify\.py', '%USERPROFILE%/.gemini/notify.py'
    [System.IO.File]::WriteAllText($HooksJsonPath, $hooksContent, [System.Text.UTF8Encoding]::new($false))
}

if (!(Test-Path $NotifyJsonPath)) {
    Invoke-WebRequest -Uri "$BaseUrl/hooks/notify.json.example?t=$Timestamp" -Headers @{ "Cache-Control" = "no-cache"; "Pragma" = "no-cache" } -OutFile $NotifyJsonPath -UseBasicParsing
}

# 4. Configure Antigravity CLI Settings (statusLine command)
$settingsPaths = @(
    "$env:USERPROFILE\.gemini\antigravity-cli\settings.json",
    "$env:USERPROFILE\.gemini\settings.json",
    "$env:LOCALAPPDATA\agy\settings.json",
    "$env:APPDATA\agy\settings.json"
)

$cleanPyPath = $StatuslinePyPath -replace '\\', '/'
$statusLineCommand = "python $cleanPyPath"

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
        [System.IO.File]::WriteAllText($sPath, $jsonOut, [System.Text.UTF8Encoding]::new($false))
    } catch {}
}

# 5. Append to PowerShell Profile if not present
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

# 6. Auto-sync existing active Antigravity session
try {
    & python "$BinDir\agi-auth.py" sync | Out-Null
} catch {}

Write-Host ""
Write-Host "==> Installation / Update successful!" -ForegroundColor Green
Write-Host ""
Write-Host "Features Installed:" -ForegroundColor White
Write-Host "  [OK] agi-auth CLI         - Multi-account OAuth Manager & Launcher" -ForegroundColor Green
Write-Host "  [OK] agi Shortcut         - Fast launcher with --dangerously-skip-permissions" -ForegroundColor Green
Write-Host "  [OK] Antigravity Statusline - Real-time model, branch, remain context & 5h/7d quota bars" -ForegroundColor Green
Write-Host "  [OK] Task & Telegram Hooks - Speech TTS & Telegram notifications on task completion" -ForegroundColor Green
Write-Host ""
Write-Host "Usage:" -ForegroundColor White
Write-Host "  agi-auth login          - Direct Google OAuth login, save & auto-launch agi" -ForegroundColor Cyan
Write-Host "  agi-auth list           - List all accounts, Email, Plan & Quota (Remain 5h/7d)" -ForegroundColor Cyan
Write-Host "  agi-auth switch <email> - Switch account (by Number or Email) & launch agi" -ForegroundColor Cyan
Write-Host "  agi-auth remove <email> - Remove an account" -ForegroundColor Cyan
Write-Host "  agi-auth sync           - Auto-sync active Antigravity session into accounts" -ForegroundColor Cyan
Write-Host "  agi-auth notify <token> <chat_id> - Config Telegram Bot Token & Chat ID" -ForegroundColor Cyan
Write-Host "  agi                     - Launch Antigravity CLI with statusline" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ready to use! Try running: agi-auth list" -ForegroundColor Gray


