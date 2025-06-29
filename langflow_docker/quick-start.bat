@echo off
echo =======================================
echo Langflow Quick Setup (Official Image)
echo =======================================

echo.
echo [1] Checking Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker not found! Please install Docker Desktop.
    pause
    exit /b 1
)
echo ✓ Docker is available

echo.
echo [2] Pulling latest Langflow image...
docker pull langflowai/langflow:latest
if errorlevel 1 (
    echo ERROR: Failed to pull Langflow image
    pause
    exit /b 1
)

echo.
echo [3] Starting PostgreSQL...
docker compose up -d postgres
echo Waiting for PostgreSQL to be ready...
timeout /t 15 /nobreak >nul

echo.
echo [4] Starting Langflow...
docker compose up -d langflow
echo Starting Langflow... This may take 2-3 minutes...
timeout /t 30 /nobreak >nul

echo.
echo [5] Checking status...
docker compose ps

echo.
echo [6] Checking logs...
echo --- Recent Langflow logs ---
docker compose logs langflow --tail=10

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
echo   docker compose logs langflow -f    (follow logs)
echo   docker compose ps                  (check status)
echo   docker compose down                (stop all)
echo   docker compose restart langflow    (restart Langflow)
echo.
echo If Langflow is not ready yet, wait 1-2 minutes and refresh the browser.
echo.
pause
