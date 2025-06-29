@echo off
echo ================================
echo    🛑 Langflow Stop
echo ================================

echo.
echo Stopping Langflow...
docker stop langflow_easy

echo.
echo ✅ Langflow stopped!
echo.
echo To start again: start.bat
echo To remove completely: cleanup.bat
echo.
pause
