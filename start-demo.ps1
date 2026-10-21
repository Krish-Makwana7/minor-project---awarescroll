# AwareScroll AI + FocusLock — Cross-Device Interactive Demo Launcher
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   AwareScroll AI + FocusLock: Cross-Device Demo Client   " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Launching web application with cross-device host sharing..." -ForegroundColor Green
Write-Host "You can open the demo on your laptop, desktop, tablet, or smartphone!" -ForegroundColor Gray
Write-Host ""

Set-Location "$PSScriptRoot\web"

# Start Vite server with host exposed
npm run dev -- --host --open
