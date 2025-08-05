@echo off
REM Langflow Docker Setup Script for Windows
REM This script helps you build and run Langflow with uv

setlocal EnableDelayedExpansion

REM Colors (Windows doesn't support colors in basic cmd, but we'll add structure)
set "INFO=[INFO]"
set "SUCCESS=[SUCCESS]"
set "WARNING=[WARNING]"
set "ERROR=[ERROR]"

REM Check if Docker is running
:check_docker
echo %INFO% Checking Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo %ERROR% Docker is not installed or not running
    exit /b 1
)

docker compose version >nul 2>&1
if errorlevel 1 (
    echo %ERROR% Docker Compose is not installed
    exit /b 1
)

echo %SUCCESS% Docker is ready
goto :eof

REM Build the Docker image
:build_image
echo %INFO% Building Langflow Docker image with uv...
docker compose build --no-cache
if errorlevel 1 (
    echo %ERROR% Failed to build image
    exit /b 1
)
echo %SUCCESS% Image built successfully
goto :eof

REM Start services
:start_services
echo %INFO% Starting Langflow services...
docker compose up -d
if errorlevel 1 (
    echo %ERROR% Failed to start services
    exit /b 1
)
echo %SUCCESS% Services started

echo %INFO% Waiting for services to be ready...
timeout /t 10 /nobreak >nul

call :check_services
goto :eof

REM Check service health
:check_services
echo %INFO% Checking service health...

REM Check PostgreSQL
docker compose exec postgres pg_isready -U langflow >nul 2>&1
if not errorlevel 1 (
    echo %SUCCESS% PostgreSQL is ready
) else (
    echo %WARNING% PostgreSQL is not ready yet
)

REM Check Redis
docker compose exec redis redis-cli ping >nul 2>&1
if not errorlevel 1 (
    echo %SUCCESS% Redis is ready
) else (
    echo %WARNING% Redis is not ready yet
)

REM Check Langflow
timeout /t 5 /nobreak >nul
curl -f http://localhost:7860/health >nul 2>&1
if not errorlevel 1 (
    echo %SUCCESS% Langflow is ready
    echo %SUCCESS% Access Langflow at: http://localhost:7860
) else (
    echo %WARNING% Langflow is starting up... Please wait a few more seconds
)
goto :eof

REM Show logs
:show_logs
echo %INFO% Showing Langflow logs...
docker compose logs -f langflow
goto :eof

REM Stop services
:stop_services
echo %INFO% Stopping services...
docker compose down
echo %SUCCESS% Services stopped
goto :eof

REM Clean up everything
:cleanup
echo %WARNING% This will remove all containers, volumes, and data!
set /p "choice=Are you sure? (y/N): "
if /i "!choice!"=="y" (
    echo %INFO% Cleaning up...
    docker compose down -v --remove-orphans
    docker system prune -f
    echo %SUCCESS% Cleanup completed
) else (
    echo %INFO% Cleanup cancelled
)
goto :eof

REM Show help
:show_help
echo Langflow Docker Management Script for Windows
echo.
echo Usage: %~nx0 [COMMAND]
echo.
echo Commands:
echo   build     Build the Docker image
echo   start     Start all services
echo   stop      Stop all services
echo   restart   Restart all services
echo   logs      Show Langflow logs
echo   status    Check service status
echo   cleanup   Remove all containers and volumes
echo   help      Show this help message
echo.
echo Examples:
echo   %~nx0 build
echo   %~nx0 start
echo   %~nx0 logs
echo   %~nx0 restart
goto :eof

REM Main script logic
if "%1"=="build" (
    call :check_docker
    call :build_image
) else if "%1"=="start" (
    call :check_docker
    call :start_services
) else if "%1"=="stop" (
    call :stop_services
) else if "%1"=="restart" (
    call :stop_services
    timeout /t 2 /nobreak >nul
    call :start_services
) else if "%1"=="logs" (
    call :show_logs
) else if "%1"=="status" (
    call :check_services
) else if "%1"=="cleanup" (
    call :cleanup
) else if "%1"=="help" (
    call :show_help
) else if "%1"=="--help" (
    call :show_help
) else if "%1"=="-h" (
    call :show_help
) else if "%1"=="" (
    call :show_help
) else (
    echo %ERROR% Unknown command: %1
    call :show_help
    exit /b 1
)
