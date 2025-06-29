@echo off
echo ================================
echo  🔧 Port Cleanup & Fix
echo ================================

echo.
echo [1] Finding what's using port 7860...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":7860" ^| findstr "LISTENING"') do (
    echo Found process %%a using port 7860
    echo Killing process %%a...
    taskkill /f /pid %%a 2>nul
)

echo.
echo [2] Stopping ALL langflow containers...
for /f %%i in ('docker ps -q --filter "name=langflow"') do (
    echo Stopping container %%i...
    docker stop %%i 2>nul
    docker rm %%i 2>nul
)

docker stop langflow_easy 2>nul
docker rm langflow_easy 2>nul
docker stop langflow_simple 2>nul  
docker rm langflow_simple 2>nul
docker stop langflow_app 2>nul
docker rm langflow_app 2>nul

echo.
echo [3] Waiting for port to be freed...
timeout /t 5 /nobreak >nul

echo.
echo [4] Checking port availability...
netstat -ano | findstr ":7860" | findstr "LISTENING"
if not errorlevel 1 (
    echo ⚠ Port still in use, trying to free it...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":7860" ^| findstr "LISTENING"') do (
        taskkill /f /pid %%a 2>nul
    )
    timeout /t 3 /nobreak >nul
)

echo.
echo [5] Starting fresh Langflow container...
docker run -d ^
  --name langflow_easy ^
  -p 7860:7860 ^
  -e LANGFLOW_HOST=0.0.0.0 ^
  -e LANGFLOW_PORT=7860 ^
  -e LANGFLOW_BACKEND_URL=http://localhost:7860 ^
  -e LANGFLOW_FRONTEND_URL=http://localhost:7860 ^
  -e LANGFLOW_SERVER_URL=http://localhost:7860 ^
  -e LANGFLOW_AUTO_LOGIN=false ^
  -e LANGFLOW_SUPERUSER=admin ^
  -e LANGFLOW_SUPERUSER_PASSWORD=admin123 ^
  -e LANGFLOW_SECRET_KEY=langflow-secret-key-12345 ^
  -e LANGFLOW_NEW_USER_IS_ACTIVE=true ^
  -v langflow_clean:/app/langflow ^
  langflowai/langflow:latest

if errorlevel 1 (
    echo.
    echo ❌ Still failed to start. Trying different port...
    echo.
    echo [6] Starting on port 7861 instead...
    docker run -d ^
      --name langflow_easy ^
      -p 7861:7860 ^
      -e LANGFLOW_HOST=0.0.0.0 ^
      -e LANGFLOW_PORT=7860 ^
      -e LANGFLOW_BACKEND_URL=http://localhost:7861 ^
      -e LANGFLOW_FRONTEND_URL=http://localhost:7861 ^
      -e LANGFLOW_SERVER_URL=http://localhost:7861 ^
      -e LANGFLOW_AUTO_LOGIN=false ^
      -e LANGFLOW_SUPERUSER=admin ^
      -e LANGFLOW_SUPERUSER_PASSWORD=admin123 ^
      -e LANGFLOW_SECRET_KEY=langflow-secret-key-12345 ^
      -e LANGFLOW_NEW_USER_IS_ACTIVE=true ^
      -v langflow_clean:/app/langflow ^
      langflowai/langflow:latest
    
    if errorlevel 1 (
        echo.
        echo ❌ Failed to start on both ports
        echo Checking what's running...
        docker ps -a --filter "name=langflow"
        echo.
        echo Manual cleanup may be needed:
        echo 1. Restart Docker Desktop
        echo 2. Or restart computer
        pause
        exit /b 1
    ) else (
        set LANGFLOW_URL=http://localhost:7861
        echo ✅ Started on port 7861
    )
) else (
    set LANGFLOW_URL=http://localhost:7860
    echo ✅ Started on port 7860
)

echo.
echo [7] Waiting for startup...
timeout /t 45 /nobreak >nul

echo.
echo [8] Testing connection...
curl -f %LANGFLOW_URL% >nul 2>&1
if errorlevel 1 (
    echo ⚠ Connection test failed, but container might still be starting
) else (
    echo ✅ Connection successful!
)

echo.
echo [9] Container status...
docker ps --filter name=langflow_easy

echo.
echo ================================
echo ✅ Cleanup Complete!
echo ================================
echo.
if defined LANGFLOW_URL (
    echo 🌐 Langflow URL: %LANGFLOW_URL%
) else (
    echo 🌐 Langflow URL: http://localhost:7860
)
echo 👤 Username: admin
echo 🔑 Password: admin123
echo.
echo 💡 Important:
echo 1. Clear browser cache (Ctrl+Shift+Delete)
echo 2. Use incognito mode for testing
echo 3. If URL is port 7861, use that instead
echo.
pause

if defined LANGFLOW_URL (
    start %LANGFLOW_URL%
) else (
    start http://localhost:7860
)
