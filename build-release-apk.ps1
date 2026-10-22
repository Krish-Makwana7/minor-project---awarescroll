# Release APK Publisher for Native AwareScroll AI (Jetpack Compose + Accessibility + Usage Monitoring)
param(
    [string]$OutputFile = "$PSScriptRoot\awarescroll-v1.0-release.apk"
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   AwareScroll AI: Native Android Release APK Publisher   " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

$env:JAVA_HOME = "C:\Users\Asus\.jdks\jbr-17.0.14"
$env:ANDROID_HOME = "C:\Users\Asus\AppData\Local\Android\Sdk"
$gradleBin = "C:\Users\Asus\.gradle\wrapper\dists\gradle-8.13-bin\5xuhj0ry160q40clulazy9h7d\gradle-8.13\bin\gradle.bat"

Write-Host "Compiling native Android Release APK with Jetpack Compose & Background Services..." -ForegroundColor Green
& $gradleBin -p mobile assembleRelease

$generatedApk = "$PSScriptRoot\mobile\app\build\outputs\apk\release\app-release.apk"
if (-not (Test-Path $generatedApk)) {
    $generatedApk = "$PSScriptRoot\mobile\app\build\outputs\apk\release\app-release-unsigned.apk"
}

if (Test-Path $generatedApk) {
    Copy-Item $generatedApk $OutputFile -Force
    Copy-Item $generatedApk "$PSScriptRoot\awarescroll-release.apk" -Force
    Write-Host ""
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host " SUCCESS: Native Release APK published at:" -ForegroundColor Green
    Write-Host "  $OutputFile" -ForegroundColor Yellow
    Write-Host "  $PSScriptRoot\awarescroll-release.apk" -ForegroundColor Yellow
    Write-Host "==========================================================" -ForegroundColor Green
} else {
    Write-Host "Build failed: Release APK was not generated." -ForegroundColor Red
}

Set-Location $PSScriptRoot
