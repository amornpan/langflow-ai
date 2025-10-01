@echo off
echo ================================
echo  🔧 Fix SSE URL Configuration
echo ================================

echo.
echo [1] Stopping current container...
docker stop langflow_easy 2>nul
docker rm langflow_easy 2>nul

echo.
echo [2] Starting with proper SSE configuration...

docker run -d ^
  --name langflow_easy ^
  -p 7860:7860 ^
  -e LANGFLOW_HOST=0.0.0.0 ^
  -e LANGFLOW_PORT=7860 ^
  -e LANGFLOW_BACKEND_URL=http://localhost:7860 ^
  -e LANGFLOW_FRONTEND_URL=http://localhost:7860 ^
  -e LANGFLOW_SERVER_URL=http://localhost:7860 ^
  -e LANGFLOW_API_URL=http://localhost:7860/api ^
  -e LANGFLOW_SSE_URL=http://localhost:7860/sse ^
  -e LANGFLOW_AUTO_LOGIN=false ^
  -e LANGFLOW_SUPERUSER=admin ^
  -e LANGFLOW_SUPERUSER_PASSWORD=admin123 ^
  -e LANGFLOW_SECRET_KEY=langflow-secret-key-12345 ^
  -e LANGFLOW_NEW_USER_IS_ACTIVE=true ^
  -e LANGFLOW_DEV=false ^
  -e LANGFLOW_DATABASE_URL=sqlite:////app/langflow/langflow.db ^
  -v langflow_fixed:/app/langflow ^
  langflowai/langflow:latest ^
  langflow run --host 0.0.0.0 --port 7860

if errorlevel 1 (
    echo ERROR: Failed to start container
    docker logs langflow_easy
    pause
    exit /b 1
)

echo ✅ Container started

echo.
echo [3] Waiting for Langflow to initialize...
timeout /t 60 /nobreak >nul

echo.
echo [4] Checking container health...
docker ps --filter name=langflow_easy --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo.
echo [5] Testing endpoints...
echo Testing main endpoint...
curl -s -I http://localhost:7860 | findstr "HTTP"

echo Testing SSE endpoint...
curl -s -I http://localhost:7860/sse | findstr "HTTP"

echo.
echo [6] Recent logs...
docker logs langflow_easy --tail=15

echo.
echo ================================
echo ✅ Configuration Fixed!
echo ================================
echo.
echo 🌐 Main URL: http://localhost:7860
echo 🔄 SSE URL: http://localhost:7860/sse
echo 🔑 Login: admin / admin123
echo.
echo 💡 Important:
echo 1. Clear browser cache completely
echo 2. Use incognito mode for testing
echo 3. If still issues, restart browser
echo.
pause

echo Opening in browser...
start http://localhost:7860
