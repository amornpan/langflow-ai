@echo off
echo ================================
echo    🗑️ Langflow Cleanup
echo ================================

echo.
echo This will remove Langflow and ALL data!
set /p confirm="Are you sure? (y/N): "

if /i "%confirm%" NEQ "y" (
    echo Cancelled.
    pause
    exit /b
)

echo.
echo Removing Langflow container and data...
docker stop langflow_easy 2>nul
docker rm langflow_easy 2>nul
docker volume rm langflow_data 2>nul

echo.
echo ✅ Cleanup complete!
echo.
echo To start fresh: start.bat
echo.
pause
