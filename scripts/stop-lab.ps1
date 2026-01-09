# ============================================================
# Hadoop/Spark Teaching Lab - Windows PowerShell Stop Script
# ============================================================

$ProjectDir = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectDir

Write-Host "Stopping Hadoop/Spark Teaching Lab..." -ForegroundColor Blue

docker-compose down

Write-Host "✓ Cluster stopped successfully" -ForegroundColor Green
Write-Host ""
Write-Host "Note: Data volumes are preserved. To remove all data, run:"
Write-Host "  docker-compose down -v"

