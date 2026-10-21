# AwareScroll Quick Sync Script
# Usage: .\sync.ps1 "your commit message"
# If no message given, uses a timestamped auto-message

param(
    [string]$Message = ""
)

$env:PATH = "C:\PortableGit\cmd;$env:PATH"
$GIT = "C:\PortableGit\cmd\git.exe"

if ($Message -eq "") {
    $Message = "chore: auto-sync $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
}

Write-Host "`n[sync] Staging all changes..." -ForegroundColor Cyan
& $GIT add .

$status = & $GIT status --short
if (-not $status) {
    Write-Host "[sync] Nothing to commit - working tree clean." -ForegroundColor Yellow
    exit 0
}

Write-Host "[sync] Changes to commit:" -ForegroundColor Cyan
$status | ForEach-Object { Write-Host "  $_" }

Write-Host "`n[sync] Committing: '$Message'" -ForegroundColor Cyan
& $GIT commit -m $Message

Write-Host "`n[sync] Pushing to GitHub..." -ForegroundColor Cyan
& $GIT -c core.compression=0 -c http.postBuffer=524288000 -c http.version=HTTP/1.1 push origin main 2>&1

if ($LASTEXITCODE -eq 0) {
    $sha = & $GIT rev-parse --short HEAD
    Write-Host "`n[sync] SUCCESS - $sha pushed to github.com/Krish-Makwana7/minor-project---awarescroll" -ForegroundColor Green
} else {
    Write-Host "`n[sync] Push failed. Check connection and try again." -ForegroundColor Red
    exit 1
}
