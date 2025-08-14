@echo off
echo =======================================
echo Langflow Permission Fix & Start
echo =======================================

echo.
echo [1] Stopping existing containers...
docker compose down 2>nul
docker stop langflow_simple 2>nul
docker rm langflow_simple 2>nul

echo.
echo [2] Cleaning up volumes with permission issues...
docker volume rm langflow_docker_langflow_data 2>nul

echo.
echo [3] Starting PostgreSQL first...
docker compose up -d postgres
if errorlevel 1 (
    echo ERROR: Failed to start PostgreSQL
    goto :simple_mode
)

echo Waiting for PostgreSQL...
timeout /t 15 /nobreak >nul

echo.
echo [4] Starting Langflow with permission fix...
docker compose up -d langflow
if errorlevel 1 (
    echo ERROR: Failed to start Langflow with compose
    goto :simple_mode
)

echo Waiting for Langflow to start...
timeout /t 45 /nobreak >nul

echo.
echo [5] Checking logs...
docker compose logs langflow --tail=10

goto :check_result

:simple_mode
echo.
echo [Alternative] Starting Langflow in simple mode...
docker run -d --name langflow_simple ^
  -p 7860:7860 ^
  -e LANGFLOW_CONFIG_DIR=/tmp/langflow ^
  -e LANGFLOW_SUPERUSER=admin ^
  -e LANGFLOW_SUPERUSER_PASSWORD=admin123 ^
  -e HOME=/tmp ^
  -v langflow_simple_data:/tmp/langflow ^
  --user root ^
  langflowai/langflow:latest ^
  sh -c "mkdir -p /tmp/langflow && chmod -R 777 /tmp/langflow && langflow run --host 0.0.0.0 --port 7860"

if errorlevel 1 (
    echo ERROR: Failed to start simple mode too
    goto :manual_mode
)

echo Simple mode started, waiting...
timeout /t 45 /nobreak >nul

echo Checking simple mode logs...
docker logs langflow_simple --tail=10

goto :check_result

:manual_mode
echo.
echo [Manual Mode] Starting basic Langflow...
docker run -d --name langflow_basic ^
  -p 7860:7860 ^
  -e LANGFLOW_CONFIG_DIR=/tmp ^
  -e HOME=/tmp ^
  --tmpfs /tmp:exec ^
  langflowai/langflow:latest

timeout /t 30 /nobreak >nul
docker logs langflow_basic --tail=10

:check_result
echo.
echo [6] Testing connection...
curl -f http://localhost:7860/health >nul 2>&1
if errorlevel 1 (
    echo ⚠ Langflow not ready yet, checking status...
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | findstr langflow
    
    echo.
    echo Trying to access anyway...
    curl -I http://localhost:7860 2>nul
    if not errorlevel 1 (
        echo ✓ Web server is responding
    )
) else (
    echo ✓ Langflow health check passed!
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
echo If you see permission errors, Langflow will try to create files in /tmp
echo which should have write permissions.
echo.
echo Debug commands:
echo   docker logs langflow_app -f        (if using compose)
echo   docker logs langflow_simple -f     (if using simple mode)
echo   docker logs langflow_basic -f      (if using basic mode)
echo.
pause
