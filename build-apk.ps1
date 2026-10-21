# Build script for AwareScroll Cross-Platform Demo APK
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   AwareScroll AI + FocusLock: Android APK Builder        " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

$env:JAVA_HOME = "C:\Users\Asus\.jdks\jbr-17.0.14"
$env:ANDROID_HOME = "C:\Users\Asus\AppData\Local\Android\Sdk"
$gradleBin = "C:\Users\Asus\.gradle\wrapper\dists\gradle-8.13-bin\5xuhj0ry160q40clulazy9h7d\gradle-8.13\bin\gradle.bat"

Write-Host "Step 1: Building web assets with Vite..." -ForegroundColor Green
Set-Location "$PSScriptRoot\web"
npm run build

Write-Host "Step 2: Syncing native mobile projects (Android & iOS)..." -ForegroundColor Green
npx cap sync

# Ensure compileOptions Java 17 compatibility
$capBuildGradle = "$PSScriptRoot\web\android\app\capacitor.build.gradle"
if (Test-Path $capBuildGradle) {
    (Get-Content $capBuildGradle) -replace 'VERSION_21', 'VERSION_17' | Set-Content $capBuildGradle
}

Write-Host "Step 3: Compiling native Android APK with Gradle..." -ForegroundColor Green
& $gradleBin -p android assembleDebug

if (Test-Path "$PSScriptRoot\web\android\app\build\outputs\apk\debug\app-debug.apk") {
    Copy-Item "$PSScriptRoot\web\android\app\build\outputs\apk\debug\app-debug.apk" "$PSScriptRoot\awarescroll-demo.apk" -Force
    Write-Host ""
    Write-Host "SUCCESS: Demo APK generated at:" -ForegroundColor Green
    Write-Host "  $PSScriptRoot\awarescroll-demo.apk" -ForegroundColor Yellow
} else {
    Write-Host "Build failed or APK not found." -ForegroundColor Red
}

Set-Location $PSScriptRoot
