# deploy.ps1 - Simple Deploy Script

Write-Host "Starting deployment to GitHub..." -ForegroundColor Cyan

# 1. Check Hugo Build
Write-Host "Checking build..." -ForegroundColor Yellow
if (Get-Command hugo -ErrorAction SilentlyContinue) {
    hugo
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Local build failed." -ForegroundColor Red
        Pause
        exit
    }
} else {
    Write-Host "Warning: Hugo not found, skipping check." -ForegroundColor DarkGray
}

# 2. Get Commit Message
$commitMsg = Read-Host "Enter commit message (Press Enter for default)"
if ([string]::IsNullOrWhiteSpace($commitMsg)) {
    $date = Get-Date -Format "yyyy-MM-dd HH:mm"
    $commitMsg = "Update content: $date"
}

# 3. Git Operations
Write-Host "Executing Git Add..." -ForegroundColor Green
git add .

Write-Host "Executing Git Commit..." -ForegroundColor Green
git commit -m "$commitMsg"

Write-Host "Pushing to GitHub (main branch)..." -ForegroundColor Green
git push origin main

# 4. Check Result
if ($LASTEXITCODE -eq 0) {
    Write-Host "Success! GitHub Actions will update your site shortly." -ForegroundColor Cyan
} else {
    Write-Host "Failed! Please check your network or git status." -ForegroundColor Red
}

Pause