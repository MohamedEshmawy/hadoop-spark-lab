# ============================================================
# Hadoop/Spark Teaching Lab - Windows PowerShell Startup Script
# ============================================================

$ErrorActionPreference = "Stop"

$ProjectDir = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectDir

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║     Hadoop/Spark Teaching Lab - Starting Cluster          ║" -ForegroundColor Blue
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Blue
Write-Host ""

# Check Docker
Write-Host "[1/5] Checking Docker..." -ForegroundColor Yellow
$dockerCheck = docker info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    exit 1
}
Write-Host "Docker is running" -ForegroundColor Green

# Build images
Write-Host "[2/5] Building Docker images - this may take a few minutes on first run..." -ForegroundColor Yellow
docker-compose build --quiet

# Start cluster
Write-Host "[3/5] Starting cluster services..." -ForegroundColor Yellow
docker-compose up -d

# Wait for services
Write-Host "[4/5] Waiting for services to be ready..." -ForegroundColor Yellow
Write-Host "This may take 1-2 minutes on first startup..."

# Wait for NameNode
Write-Host -NoNewline "  Waiting for NameNode..."
$ready = $false
for ($i = 1; $i -le 60; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:9870" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
        Write-Host " OK" -ForegroundColor Green
        $ready = $true
        break
    } catch {
        Write-Host -NoNewline "."
        Start-Sleep -Seconds 2
    }
}
if (-not $ready) { Write-Host " timeout" -ForegroundColor Yellow }

# Wait for ResourceManager
Write-Host -NoNewline "  Waiting for ResourceManager..."
$ready = $false
for ($i = 1; $i -le 60; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8088" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
        Write-Host " OK" -ForegroundColor Green
        $ready = $true
        break
    } catch {
        Write-Host -NoNewline "."
        Start-Sleep -Seconds 2
    }
}
if (-not $ready) { Write-Host " timeout" -ForegroundColor Yellow }

# Wait for Jupyter
Write-Host -NoNewline "  Waiting for Jupyter Lab..."
$ready = $false
for ($i = 1; $i -le 30; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8888" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
        Write-Host " OK" -ForegroundColor Green
        $ready = $true
        break
    } catch {
        Write-Host -NoNewline "."
        Start-Sleep -Seconds 2
    }
}
if (-not $ready) { Write-Host " timeout" -ForegroundColor Yellow }

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║           Cluster is Ready!                                ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Access the following UIs:"
Write-Host "  HDFS NameNode:        " -NoNewline; Write-Host "http://localhost:9870" -ForegroundColor Cyan
Write-Host "  YARN ResourceManager: " -NoNewline; Write-Host "http://localhost:8088" -ForegroundColor Cyan
Write-Host "  Spark History Server: " -NoNewline; Write-Host "http://localhost:18080" -ForegroundColor Cyan
Write-Host "  Jupyter Lab:          " -NoNewline; Write-Host "http://localhost:8888 (token: hadooplab)" -ForegroundColor Cyan
Write-Host ""
Write-Host "To stop the cluster: .\scripts\stop-lab.ps1"

