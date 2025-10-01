@echo off
echo =======================================
echo Simple Langflow Runner (No DB)
echo =======================================

echo.
echo [1] Cleaning up any existing containers...
docker stop langflow_simple 2>nul
docker rm langflow_simple 2>nul

echo.
echo [2] Starting Langflow in simple mode...
echo This uses temporary storage and no database
echo.

docker run -d ^
  --name langflow_simple ^
  -p 7860:7860 ^
  -e LANGFLOW_AUTO_LOGIN=true ^
  -e LANGFLOW_SUPERUSER=admin ^
  -e LANGFLOW_SUPERUSER_PASSWORD=admin123 ^
  -e LANGFLOW_CONFIG_DIR=/tmp/langflow ^
  -e LANGFLOW_LOG_LEVEL=INFO ^
  -e HOME=/tmp ^
  --tmpfs /tmp:exec,size=1g ^
  langflowai/langflow:latest

if errorlevel 1 (
    echo ERROR: Failed to start container
    pause
    exit /b 1
)

echo ✓ Container started successfully

echo.
echo [3] Waiting for Langflow to initialize...
timeout /t 30 /nobreak >nul

echo.
echo [4] Checking container status...
docker ps --filter name=langflow_simple

echo.
echo [5] Checking logs...
docker logs langflow_simple --tail=15

echo.
echo [6] Testing connection...
for /l %%i in (1,1,10) do (
    curl -f http://localhost:7860 >nul 2>&1
    if not errorlevel 1 (
        echo ✓ Langflow is responding!
        goto :success
    )
    echo Attempt %%i/10 - waiting...
    timeout /t 5 /nobreak >nul
)

echo ⚠ Connection test failed, but container might still be starting

:success
echo.
echo =======================================
echo Langflow Started Successfully!
echo =======================================
echo.
echo 🌐 Access at: http://localhost:7860
echo 👤 Auto-login enabled (no credentials needed)
echo.
echo 📝 Useful commands:
echo   docker logs langflow_simple -f    (follow logs)
echo   docker stop langflow_simple       (stop)
echo   docker start langflow_simple      (start again)
echo   docker rm langflow_simple         (remove completely)
echo.
echo 💡 Note: This uses temporary storage only
echo    Your flows will be lost when container stops
echo.
pause
