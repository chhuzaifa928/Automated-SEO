# Watsonx Orchestrate - Disable Embedded Chat Security (PowerShell)
# This script disables security to allow anonymous access to your embedded chat

$ErrorActionPreference = "Stop"

# Configuration
$WXO_API_KEY = "ApiKey-588a0c02-828c-4e8f-b5c2-4387766fd52e"
$SERVICE_INSTANCE_URL = "https://api.eu-gb.watson-orchestrate.cloud.ibm.com/instances/919dc40a-d9fd-42b0-8bfd-15fca422a942"
$IAM_URL = "https://iam.platform.saas.ibm.com"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Watsonx Orchestrate - Disable Security (PowerShell)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Get IAM Token
Write-Host "[1/3] Requesting IAM token..." -ForegroundColor Yellow

$tokenBody = @{
    apikey = $WXO_API_KEY
} | ConvertTo-Json

try {
    $tokenResponse = Invoke-RestMethod -Uri "$IAM_URL/siusermgr/api/1.0/apikeys/token" `
        -Method Post `
        -Headers @{
        "Accept"       = "application/json"
        "Content-Type" = "application/json"
    } `
        -Body $tokenBody

    $WXO_TOKEN = $tokenResponse.token
    Write-Host "✅ Token acquired successfully" -ForegroundColor Green
}
catch {
    Write-Host "❌ Failed to get IAM token. Error:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Step 2: Disable Security
Write-Host ""
Write-Host "[2/3] Disabling embedded chat security..." -ForegroundColor Yellow

$CONFIG_ENDPOINT = "$SERVICE_INSTANCE_URL/v1/embed/secure/config"

$disablePayload = @{
    is_security_enabled = $false
} | ConvertTo-Json

try {
    $configResponse = Invoke-RestMethod -Uri $CONFIG_ENDPOINT `
        -Method Post `
        -Headers @{
        "Authorization" = "Bearer $WXO_TOKEN"
        "Content-Type"  = "application/json"
        "Accept"        = "application/json"
    } `
        -Body $disablePayload

    Write-Host "✅ Security disabled successfully!" -ForegroundColor Green
}
catch {
    Write-Host "❌ Failed to disable security. Error:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Step 3: Verify Configuration
Write-Host ""
Write-Host "[3/3] Verifying current configuration..." -ForegroundColor Yellow

try {
    $verifyResponse = Invoke-RestMethod -Uri $CONFIG_ENDPOINT `
        -Method Get `
        -Headers @{
        "Authorization" = "Bearer $WXO_TOKEN"
        "Accept"        = "application/json"
    }

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "Current Configuration:" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    $verifyResponse | ConvertTo-Json -Depth 5 | Write-Host
    Write-Host ""

    if ($verifyResponse.is_security_enabled -eq $false) {
        Write-Host "============================================================" -ForegroundColor Green
        Write-Host "✅ SUCCESS! Security is now DISABLED" -ForegroundColor Green
        Write-Host "============================================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Your embedded chat now allows anonymous access." -ForegroundColor Green
        Write-Host "The agent should work immediately in your website!" -ForegroundColor Green
        Write-Host ""
        Write-Host "⚠️  Important: Only use this for non-sensitive data." -ForegroundColor Yellow
    }
    else {
        Write-Host "⚠️  Warning: Security status is still enabled" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "❌ Failed to verify configuration. Error:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host ""
Write-Host "Done! You can now refresh your website and test the agent." -ForegroundColor Cyan
