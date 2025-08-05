@echo off
REM Langflow Docker Compose Helper

if "%1"=="start" goto start
if "%1"=="stop" goto stop
if "%1"=="restart" goto restart
if "%1"=="logs" goto logs
if "%1"=="status" goto status
if "%1"=="clean" goto clean
if "%1"=="backup" goto backup
if "%1"=="shell" goto shell
goto help

:start
echo Starting Langflow services...
docker compose up -d
goto end

:stop
echo Stopping Langflow services...
docker compose down
goto end

:restart
echo Restarting Langflow services...
docker compose restart
goto end

:logs
echo Showing Langflow logs...
docker compose logs -f langflow
goto end

:status
echo Checking service status...
docker compose ps
goto end

:clean
echo Cleaning up...
docker compose down -v
docker system prune -f
goto end

:backup
echo Creating backup...
docker compose exec postgres pg_dump -U langflow langflow > backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%.sql
echo Backup created: backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%.sql
goto end

:shell
echo Opening Langflow shell...
docker compose exec langflow bash
goto end

:help
echo Langflow Docker Compose Helper
echo.
echo Usage: %0 [command]
echo.
echo Commands:
echo   start    - Start all services
echo   stop     - Stop all services  
echo   restart  - Restart all services
echo   logs     - Show Langflow logs
echo   status   - Show service status
echo   clean    - Clean up everything
echo   backup   - Backup database
echo   shell    - Open Langflow shell
echo.

:end
