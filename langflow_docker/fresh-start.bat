@echo off
echo ================================
echo  🧹 Complete Reset
echo ================================

echo.
echo This will clean everything and restart fresh
set /p confirm="Continue? (y/N): "

if /i "%confirm%" NEQ "y" (
    echo Cancelled.
    pause
    exit /b
)

echo.
echo [1] Stopping all containers...
docker stop langflow_easy 2>nul
docker rm langflow_easy 2>nul

echo.
echo [2] Removing volumes...
docker volume rm langflow_data 2>nul

echo.
echo [3] Checking for port conflicts...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":7860"') do (
    echo Killing process %%a using port 7860
    taskkill /f /pid %%a 2>nul
)

for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8000"') do (
    echo Killing process %%a using port 8000  
    taskkill /f /pid %%a 2>nul
)

echo.
echo [4] Starting fresh Langflow...
docker run -d ^
  --name langflow_easy ^
  -p 7860:7860 ^
  -e LANGFLOW_HOST=0.0.0.0 ^
  -e LANGFLOW_PORT=7860 ^
  -e LANGFLOW_AUTO_LOGIN=false ^
  -e LANGFLOW_SUPERUSER=admin ^
  -e LANGFLOW_SUPERUSER_PASSWORD=admin123 ^
  -e LANGFLOW_SECRET_KEY=my-secret-key-123 ^
  -e LANGFLOW_NEW_USER_IS_ACTIVE=true ^
  -v langflow_fresh:/app/langflow ^
  langflowai/langflow:latest

if errorlevel 1 (
    echo ERROR: Failed to start container
    pause
    exit /b 1
)

echo.
echo [5] Waiting for startup...
timeout /t 45 /nobreak >nul

echo.
echo [6] Testing connection...
for /l %%i in (1,1,10) do (
    curl -f http://localhost:7860 >nul 2>&1
    if not errorlevel 1 (
        echo ✅ Connection successful!
        goto :success
    )
    echo Attempt %%i/10...
    timeout /t 5 /nobreak >nul
)

:success
echo.
echo ================================
echo ✅ Fresh Start Complete!
echo ================================
echo.
echo 🌐 URL: http://localhost:7860
echo 👤 Username: admin  
echo 🔑 Password: admin123
echo.
echo 💡 Tips:
echo - Clear browser cache if needed
echo - Use incognito/private browsing
echo - Check logs: docker logs langflow_easy -f
echo.
pause

start http://localhost:7860
