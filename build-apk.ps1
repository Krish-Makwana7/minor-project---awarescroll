# Build script for AwareScroll Native Android APK (Kotlin + Jetpack Compose)
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   AwareScroll AI: Native Android APK Builder             " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

$env:JAVA_HOME = "C:\Users\Asus\.jdks\jbr-17.0.14"
$env:ANDROID_HOME = "C:\Users\Asus\AppData\Local\Android\Sdk"
$gradleBin = "C:\Users\Asus\.gradle\wrapper\dists\gradle-8.13-bin\5xuhj0ry160q40clulazy9h7d\gradle-8.13\bin\gradle.bat"

Write-Host "Compiling native Android APK with Gradle..." -ForegroundColor Green
& $gradleBin -p mobile assembleDebug

$generatedApk = "$PSScriptRoot\mobile\app\build\outputs\apk\debug\app-debug.apk"
if (Test-Path $generatedApk) {
    Copy-Item $generatedApk "$PSScriptRoot\awarescroll-demo.apk" -Force
    Write-Host ""
    Write-Host "SUCCESS: Native Android APK generated at:" -ForegroundColor Green
    Write-Host "  $PSScriptRoot\awarescroll-demo.apk" -ForegroundColor Yellow
} else {
    Write-Host "Build failed or APK not found." -ForegroundColor Red
}

Set-Location $PSScriptRoot
