@echo off
echo ================================
echo  🔍 What's Using Port 7860?
echo ================================

echo.
echo [1] Checking port 7860 usage...
netstat -ano | findstr ":7860"

echo.
echo [2] All langflow containers...
docker ps -a --filter "name=langflow"

echo.
echo [3] All running containers...
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo.
echo [4] Docker compose services...
docker compose ps 2>nul

echo.
echo [5] Processes using port 7860...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":7860" ^| findstr "LISTENING"') do (
    echo Process ID: %%a
    tasklist /fi "PID eq %%a" 2>nul
)

echo.
echo ================================
echo 🛠️ Cleanup Options:
echo ================================
echo.
echo 1. Run: cleanup-and-start.bat    (automatic cleanup)
echo 2. Docker Desktop restart        (nuclear option)
echo 3. Computer restart              (ultimate nuclear)
echo.
echo Choose option 1 first!
echo.
pause
