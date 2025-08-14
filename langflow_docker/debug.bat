@echo off
echo ==================================================
echo Langflow Docker Debug Script
echo ==================================================

echo.
echo [1] Checking Docker installation...
docker --version
if errorlevel 1 (
    echo ERROR: Docker is not installed or not running!
    echo Please start Docker Desktop and try again.
    pause
    exit /b 1
)

echo.
echo [2] Checking Docker Compose...
docker compose version
if errorlevel 1 (
    echo ERROR: Docker Compose is not available!
    pause
    exit /b 1
)

echo.
echo [3] Checking current directory...
echo Current directory: %CD%
if not exist "docker-compose.yml" (
    echo ERROR: docker-compose.yml not found!
    echo Make sure you're in the correct directory.
    pause
    exit /b 1
)

echo.
echo [4] Checking for existing containers...
docker ps -a --filter "name=langflow"

echo.
echo [5] Checking Docker system info...
docker system df

echo.
echo [6] Building Docker image (with verbose output)...
echo This may take 5-10 minutes...
docker compose build --no-cache --progress=plain

if errorlevel 1 (
    echo.
    echo ERROR: Build failed!
    echo Check the error messages above.
    pause
    exit /b 1
)

echo.
echo [7] Starting services...
docker compose up -d

if errorlevel 1 (
    echo.
    echo ERROR: Failed to start services!
    echo Check the error messages above.
    pause
    exit /b 1
)

echo.
echo [8] Waiting for services to start...
timeout /t 15 /nobreak

echo.
echo [9] Checking service status...
docker compose ps

echo.
echo [10] Checking service logs...
echo --- PostgreSQL logs ---
docker compose logs postgres --tail=10

echo.
echo --- Redis logs ---
docker compose logs redis --tail=10

echo.
echo --- Langflow logs ---
docker compose logs langflow --tail=20

echo.
echo [11] Testing connectivity...
echo Testing PostgreSQL...
docker compose exec -T postgres pg_isready -U langflow
if errorlevel 1 (
    echo WARNING: PostgreSQL not ready yet
) else (
    echo SUCCESS: PostgreSQL is ready
)

echo.
echo Testing Redis...
docker compose exec -T redis redis-cli ping
if errorlevel 1 (
    echo WARNING: Redis not ready yet
) else (
    echo SUCCESS: Redis is ready
)

echo.
echo Testing Langflow...
curl -f http://localhost:7860/health 2>nul
if errorlevel 1 (
    echo WARNING: Langflow not ready yet (this is normal, may take 1-2 minutes)
    echo You can check http://localhost:7860 in your browser
) else (
    echo SUCCESS: Langflow is ready!
    echo Access it at: http://localhost:7860
)

echo.
echo ==================================================
echo Setup completed!
echo ==================================================
echo.
echo Login credentials:
echo Username: admin
echo Password: Admin123!
echo.
echo Useful commands:
echo   docker compose logs langflow -f    (follow logs)
echo   docker compose ps                  (check status)
echo   docker compose down                (stop all)
echo.
pause
