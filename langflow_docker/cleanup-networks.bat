@echo off
echo =======================================
echo Docker Network Cleanup
echo =======================================

echo.
echo [1] Stopping all containers...
docker compose down 2>nul
docker stop langflow_simple 2>nul
docker rm langflow_simple 2>nul

echo.
echo [2] Listing current networks...
docker network ls

echo.
echo [3] Cleaning up unused networks...
docker network prune -f

echo.
echo [4] Checking for conflicting networks...
docker network ls | findstr "172.20"
if not errorlevel 1 (
    echo Found conflicting networks. Removing them...
    for /f "tokens=1" %%i in ('docker network ls -q --filter "driver=bridge"') do (
        docker network inspect %%i 2>nul | findstr "172.20" >nul
        if not errorlevel 1 (
            echo Removing network %%i...
            docker network rm %%i 2>nul
        )
    )
)

echo.
echo [5] Final network list...
docker network ls

echo.
echo =======================================
echo Cleanup Complete!
echo =======================================
echo.
echo You can now run: fix-and-start.bat
echo.
pause
