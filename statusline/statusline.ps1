# Lightweight wrapper redirecting to statusline.py for backward compatibility
$pyPath = Join-Path $PSScriptRoot "statusline.py"
if (-not (Test-Path $pyPath)) {
    $pyPath = Join-Path $env:USERPROFILE ".gemini\statusline.py"
}
if (Test-Path $pyPath) {
    [Console]::In.ReadToEnd() | python $pyPath
} else {
    Write-Output "agy"
}
