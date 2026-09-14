# Watsonx Orchestrate - Disable Embedded Chat Security
# PowerShell Script for Windows

$ErrorActionPreference = "Stop"

# Configuration
$WXO_API_KEY = "ApiKey-588a0c02-828c-4e8f-b5c2-4387766fd52e"
$SERVICE_INSTANCE_URL = "https://api.eu-gb.watson-orchestrate.cloud.ibm.com/instances/919dc40a-d9fd-42b0-8bfd-15fca422a942"
$IAM_URL = "https://iam.cloud.ibm.com"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Watsonx Orchestrate - Disable Security (PowerShell)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Get IAM Token using IBM Cloud standard endpoint
Write-Host "[1/3] Requesting IAM token from IBM Cloud..." -ForegroundColor Yellow

$tokenBody = "grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=$WXO_API_KEY"

try {
    $tokenResponse = Invoke-RestMethod -Uri "$IAM_URL/identity/token" `
        -Method Post `
        -Headers @{
        "Accept"       = "application/json"
        "Content-Type" = "application/x-www-form-urlencoded"
    } `
        -Body $tokenBody

    $WXO_TOKEN = $tokenResponse.access_token
    Write-Host "✅ Token acquired successfully" -ForegroundColor Green
    Write-Host "Token type: $($tokenResponse.token_type)" -ForegroundColor Gray
}
catch {
    Write-Host "❌ Failed to get IAM token. Error:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Verify your API key is correct" -ForegroundColor Yellow
    Write-Host "2. Check if the API key has proper permissions" -ForegroundColor Yellow
    Write-Host "3. Ensure your instance URL is correct" -ForegroundColor Yellow
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
    Write-Host ""
    Write-Host "The config endpoint is: $CONFIG_ENDPOINT" -ForegroundColor Gray
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
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Cyan
        Write-Host "1. Refresh your website at http://localhost:3000" -ForegroundColor White
        Write-Host "2. The Watsonx agent should now load without the 401 error" -ForegroundColor White
        Write-Host "3. Test the chat functionality" -ForegroundColor White
    }
    else {
        Write-Host "⚠️  Warning: Security status is still enabled" -ForegroundColor Yellow
        Write-Host "The response was: $($verifyResponse.is_security_enabled)" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "❌ Failed to verify configuration. Error:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host ""
Write-Host "Script completed." -ForegroundColor Cyan
