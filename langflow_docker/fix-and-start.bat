@echo off
echo =======================================
echo Langflow Network Fix & Setup
echo =======================================

echo.
echo [1] Cleaning up existing networks and containers...
docker compose down 2>nul
docker network prune -f 2>nul
echo ✓ Cleanup completed

echo.
echo [2] Checking Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker not found! Please install Docker Desktop.
    pause
    exit /b 1
)
echo ✓ Docker is available

echo.
echo [3] Pulling latest Langflow image...
docker pull langflowai/langflow:latest
if errorlevel 1 (
    echo ERROR: Failed to pull Langflow image
    pause
    exit /b 1
)
echo ✓ Image pulled successfully

echo.
echo [4] Starting PostgreSQL...
docker compose up -d postgres
if errorlevel 1 (
    echo ERROR: Failed to start PostgreSQL
    echo Trying alternative approach...
    goto :try_simple
)
echo ✓ PostgreSQL starting...

echo Waiting for PostgreSQL to be ready...
timeout /t 15 /nobreak >nul

echo.
echo [5] Starting Langflow...
docker compose up -d langflow
if errorlevel 1 (
    echo ERROR: Failed to start Langflow
    goto :try_simple
)
echo ✓ Langflow starting...

echo Starting Langflow... This may take 2-3 minutes...
timeout /t 30 /nobreak >nul
goto :check_status

:try_simple
echo.
echo [Alternative] Starting Langflow without database...
docker run -d --name langflow_simple -p 7860:7860 langflowai/langflow:latest
if errorlevel 1 (
    echo ERROR: Failed to start simple Langflow
    pause
    exit /b 1
)
echo ✓ Simple Langflow started
timeout /t 30 /nobreak >nul

:check_status
echo.
echo [6] Checking status...
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo.
echo [7] Testing connection...
echo Testing Langflow...
curl -f http://localhost:7860/health >nul 2>&1
if errorlevel 1 (
    echo ⚠ Langflow not ready yet (normal, takes 1-2 minutes)
    echo Checking logs...
    echo.
    echo --- Recent Langflow logs ---
    if exist "docker-compose.yml" (
        docker compose logs langflow --tail=5 2>nul
    ) else (
        docker logs langflow_simple --tail=5 2>nul
    )
) else (
    echo ✓ Langflow is ready!
)

echo.
echo =======================================
echo Setup Complete!
echo =======================================
echo.
echo Access Langflow at: http://localhost:7860
echo.
echo Default login:
echo Username: admin
echo Password: admin123
echo.
echo Useful commands:
if exist "docker-compose.yml" (
    echo   docker compose logs langflow -f    (follow logs)
    echo   docker compose ps                  (check status)
    echo   docker compose down                (stop all)
    echo   docker compose restart langflow    (restart Langflow)
) else (
    echo   docker logs langflow_simple -f     (follow logs)
    echo   docker ps                          (check status)
    echo   docker stop langflow_simple        (stop)
    echo   docker start langflow_simple       (start)
)
echo.
echo If Langflow is not ready yet, wait 1-2 minutes and refresh the browser.
echo.
pause
