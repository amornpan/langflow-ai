@echo off
echo ================================
echo  🔧 Langflow Port Fix
echo ================================

echo.
echo Checking what's running on ports...
netstat -ano | findstr ":7860"
netstat -ano | findstr ":8000"

echo.
echo Stopping all langflow containers...
docker stop langflow_easy 2>nul
docker rm langflow_easy 2>nul

echo.
echo Starting Langflow on correct port 7860...

docker run -d ^
  --name langflow_easy ^
  -p 7860:7860 ^
  -e LANGFLOW_HOST=0.0.0.0 ^
  -e LANGFLOW_PORT=7860 ^
  -e LANGFLOW_AUTO_LOGIN=true ^
  -e LANGFLOW_SUPERUSER=admin ^
  -e LANGFLOW_SUPERUSER_PASSWORD=admin123 ^
  -e LANGFLOW_NEW_USER_IS_ACTIVE=true ^
  -v langflow_data:/app/langflow ^
  langflowai/langflow:latest ^
  langflow run --host 0.0.0.0 --port 7860

echo.
echo ⏳ Waiting for startup...
timeout /t 30 /nobreak >nul

echo.
echo 🔍 Checking container status...
docker ps --filter name=langflow_easy

echo.
echo 📋 Recent logs...
docker logs langflow_easy --tail=10

echo.
echo ================================
echo ✅ Fixed! Try these URLs:
echo ================================
echo.
echo 🌐 Main URL: http://localhost:7860
echo 🔄 SSE URL: http://localhost:7860/sse
echo.
echo If still having issues:
echo 1. Close all browser tabs
echo 2. Clear browser cache (Ctrl+Shift+Delete)
echo 3. Open new tab: http://localhost:7860
echo.
pause

echo Opening browser...
start http://localhost:7860
