@echo off
echo ================================
echo  🚀 Langflow Auto-Login Fix
echo ================================

echo.
echo Stopping current container...
docker stop langflow_easy 2>nul
docker rm langflow_easy 2>nul

echo.
echo Starting Langflow with proper auto-login...

docker run -d ^
  --name langflow_easy ^
  -p 7860:7860 ^
  -e LANGFLOW_AUTO_LOGIN=true ^
  -e LANGFLOW_SUPERUSER=admin ^
  -e LANGFLOW_SUPERUSER_PASSWORD=admin123 ^
  -e LANGFLOW_NEW_USER_IS_ACTIVE=true ^
  -e LANGFLOW_DISABLE_LOGS=false ^
  -v langflow_data:/app/langflow ^
  langflowai/langflow:latest

echo.
echo ⏳ Waiting for Langflow to start...
timeout /t 45 /nobreak >nul

echo.
echo 🌐 Opening Langflow...
start http://localhost:7860

echo.
echo ================================
echo ✅ Langflow Ready!
echo ================================
echo.
echo 📱 Access: http://localhost:7860
echo.
echo If auto-login doesn't work:
echo 👤 Username: admin
echo 🔑 Password: admin123
echo.
echo Or click "Sign Up" to create new account
echo.
pause
