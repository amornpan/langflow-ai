@echo off
echo ================================
echo  🐳 Docker Compose Easy Start
echo ================================

echo.
echo [1] Stopping existing services...
docker compose down 2>nul

echo.
echo [2] Pulling latest images...
docker compose pull

echo.
echo [3] Starting PostgreSQL first...
docker compose up -d postgres

echo Waiting for PostgreSQL...
timeout /t 20 /nobreak >nul

echo.
echo [4] Starting Langflow...
docker compose up -d langflow

echo.
echo [5] Waiting for services to be ready...
timeout /t 60 /nobreak >nul

echo.
echo [6] Checking service status...
docker compose ps

echo.
echo [7] Testing connection...
curl -f http://localhost:7860/health >nul 2>&1
if errorlevel 1 (
    echo ⚠ Health check failed, checking logs...
    docker compose logs langflow --tail=10
) else (
    echo ✅ Langflow is healthy!
)

echo.
echo ================================
echo ✅ Docker Compose Started!
echo ================================
echo.
echo 🌐 URL: http://localhost:7860
echo 👤 Username: admin
echo 🔑 Password: admin123
echo.
echo 🔧 Useful commands:
echo   docker compose logs langflow -f     (follow logs)
echo   docker compose ps                   (check status)
echo   docker compose down                 (stop all)
echo   docker compose restart langflow     (restart Langflow)
echo.
pause

start http://localhost:7860
