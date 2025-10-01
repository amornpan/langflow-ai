@echo off
echo ================================
echo    🚀 Langflow Easy Start
echo ================================

echo.
echo Starting Langflow (SQLite mode - no database needed)...

REM Stop any existing containers
docker stop langflow_easy 2>nul
docker rm langflow_easy 2>nul

REM Start Langflow with SQLite (simple mode)
docker run -d ^
  --name langflow_easy ^
  -p 7860:7860 ^
  -e LANGFLOW_AUTO_LOGIN=true ^
  -v langflow_data:/app/langflow ^
  langflowai/langflow:latest

echo.
echo ⏳ Waiting for Langflow to start...
timeout /t 30 /nobreak >nul

echo.
echo 🌐 Opening Langflow in browser...
start http://localhost:7860

echo.
echo ================================
echo ✅ Langflow is ready!
echo ================================
echo.
echo 📱 Access: http://localhost:7860
echo 🔑 Login: Auto (no password needed)
echo 💾 Data: Saved in Docker volume
echo.
echo 🔧 Useful commands:
echo   docker logs langflow_easy -f     (view logs)
echo   docker stop langflow_easy        (stop)
echo   docker start langflow_easy       (start again)
echo.
pause
