# Release APK Publisher for AwareScroll AI
param(
    [string]$OutputFile = "$PSScriptRoot\awarescroll-v1.0-release.apk"
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   AwareScroll AI: Production Release APK Publisher       " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

$env:JAVA_HOME = "C:\Users\Asus\.jdks\jbr-17.0.14"
$env:ANDROID_HOME = "C:\Users\Asus\AppData\Local\Android\Sdk"
$gradleBin = "C:\Users\Asus\.gradle\wrapper\dists\gradle-8.13-bin\5xuhj0ry160q40clulazy9h7d\gradle-8.13\bin\gradle.bat"

Write-Host "Step 1: Compiling production web bundle (Vite + TS)..." -ForegroundColor Green
Set-Location "$PSScriptRoot\web"
npm run build

Write-Host "Step 2: Syncing Capacitor native assets..." -ForegroundColor Green
npx cap sync

# Ensure compileOptions Java 17 compatibility
$capBuildGradle = "$PSScriptRoot\web\android\app\capacitor.build.gradle"
if (Test-Path $capBuildGradle) {
    (Get-Content $capBuildGradle) -replace 'VERSION_21', 'VERSION_17' | Set-Content $capBuildGradle
}

Write-Host "Step 3: Compiling signed Production Release APK..." -ForegroundColor Green
& $gradleBin -p android assembleRelease

$generatedApk = "$PSScriptRoot\web\android\app\build\outputs\apk\release\app-release.apk"
if (-not (Test-Path $generatedApk)) {
    # Check for unsigned fallback if needed
    $generatedApk = "$PSScriptRoot\web\android\app\build\outputs\apk\release\app-release-unsigned.apk"
}

if (Test-Path $generatedApk) {
    Copy-Item $generatedApk $OutputFile -Force
    Copy-Item $generatedApk "$PSScriptRoot\awarescroll-release.apk" -Force
    Write-Host ""
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host " SUCCESS: Production Release APK published at:" -ForegroundColor Green
    Write-Host "  $OutputFile" -ForegroundColor Yellow
    Write-Host "  $PSScriptRoot\awarescroll-release.apk" -ForegroundColor Yellow
    Write-Host "==========================================================" -ForegroundColor Green
} else {
    Write-Host "Build failed: Release APK was not generated." -ForegroundColor Red
}

Set-Location $PSScriptRoot
