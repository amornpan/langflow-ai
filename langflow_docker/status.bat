@echo off
echo ================================
echo    📋 Langflow Status
echo ================================

echo.
echo Container Status:
docker ps --filter name=langflow_easy --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo.
echo Recent Logs:
docker logs langflow_easy --tail=10 2>nul

echo.
echo Testing Connection:
curl -f http://localhost:7860 >nul 2>&1
if errorlevel 1 (
    echo ❌ Langflow not responding
    echo Try: start.bat
) else (
    echo ✅ Langflow is running
    echo 🌐 Access: http://localhost:7860
)

echo.
pause
