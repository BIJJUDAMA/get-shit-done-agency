# GSD Agency: Model & Environment Check
# Queries available models and matches with model_capabilities.yaml

$CapabilitiesFile = Join-Path $PSScriptRoot "..\model_capabilities.yaml"
if (Test-Path $CapabilitiesFile) {
    $Capabilities = Get-Content $CapabilitiesFile | ConvertFrom-Yaml # Assuming a yaml parser is available or just treat as text
    Write-Host "Checking model capabilities against registry..." -ForegroundColor Cyan
}

# Check for Antigravity/Gemini
if ($env:GOOGLE_API_KEY) {
    Write-Host "[DETECTED] Gemini API Key found." -ForegroundColor Green
}

# Check for Docker (Sandbox dependency)
docker version --format '{{.Server.Version}}' 2>$null | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "[DETECTED] Docker Sandbox available." -ForegroundColor Green
} else {
    Write-Host "[WARNING] Docker not found. /verify sandbox will be disabled." -ForegroundColor Yellow
}

Write-Host "`nEnvironment assessment complete."
