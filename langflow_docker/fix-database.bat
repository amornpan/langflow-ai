@echo off
echo =======================================
echo Langflow Database Migration Fix
echo =======================================

echo.
echo [1] Stopping existing containers...
docker compose down 2>nul

echo.
echo [2] Cleaning up old volumes...
docker volume rm langflow_docker_langflow_data 2>nul

echo.
echo [3] Starting PostgreSQL...
docker compose up -d postgres
if errorlevel 1 (
    echo ERROR: Failed to start PostgreSQL
    goto :simple_without_db
)

echo Waiting for PostgreSQL to be ready...
timeout /t 20 /nobreak >nul

echo.
echo [4] Verifying database connection...
docker compose exec postgres pg_isready -U langflow
if errorlevel 1 (
    echo ERROR: PostgreSQL not ready
    goto :simple_without_db
)

echo ✓ PostgreSQL is ready

echo.
echo [5] Running manual database migration...
docker compose run --rm langflow-migration
if errorlevel 1 (
    echo WARNING: Migration failed, trying alternative method...
    
    echo Running migration inside Langflow container...
    docker compose run --rm ^
      -e LANGFLOW_DATABASE_URL=postgresql://langflow:langflow123@postgres:5432/langflow ^
      -e LANGFLOW_CONFIG_DIR=/tmp/langflow ^
      -e HOME=/tmp ^
      --user root ^
      langflow ^
      sh -c "mkdir -p /tmp/langflow && chmod -R 777 /tmp/langflow && python -m alembic upgrade head"
    
    if errorlevel 1 (
        echo ERROR: Manual migration also failed
        goto :simple_without_db
    )
)

echo ✓ Database migration completed

echo.
echo [6] Starting Langflow...
docker compose up -d langflow

echo Waiting for Langflow to start...
timeout /t 45 /nobreak >nul

echo.
echo [7] Checking logs...
docker compose logs langflow --tail=15

goto :check_result

:simple_without_db
echo.
echo [Alternative] Starting Langflow without database...
echo This uses SQLite instead of PostgreSQL
echo.

docker compose down 2>nul

docker run -d ^
  --name langflow_sqlite ^
  -p 7860:7860 ^
  -e LANGFLOW_AUTO_LOGIN=false ^
  -e LANGFLOW_SUPERUSER=admin ^
  -e LANGFLOW_SUPERUSER_PASSWORD=admin123 ^
  -e LANGFLOW_CONFIG_DIR=/tmp/langflow ^
  -e LANGFLOW_LOG_LEVEL=INFO ^
  -e HOME=/tmp ^
  -v langflow_sqlite_data:/tmp/langflow ^
  --user root ^
  langflowai/langflow:latest ^
  sh -c "mkdir -p /tmp/langflow && chmod -R 777 /tmp/langflow && langflow run --host 0.0.0.0 --port 7860"

if errorlevel 1 (
    echo ERROR: Failed to start SQLite mode
    pause
    exit /b 1
)

echo ✓ SQLite mode started
timeout /t 30 /nobreak >nul

echo Checking SQLite mode logs...
docker logs langflow_sqlite --tail=10

:check_result
echo.
echo [8] Testing connection...
for /l %%i in (1,1,12) do (
    curl -f http://localhost:7860/health >nul 2>&1
    if not errorlevel 1 (
        echo ✓ Langflow health check passed!
        goto :success
    )
    
    curl -I http://localhost:7860 >nul 2>&1
    if not errorlevel 1 (
        echo ✓ Langflow web server is responding
        goto :success
    )
    
    echo Attempt %%i/12 - waiting...
    timeout /t 10 /nobreak >nul
)

echo ⚠ Connection test failed, but checking final status...
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | findstr langflow

:success
echo.
echo =======================================
echo Setup Complete!
echo =======================================
echo.
echo 🌐 Access Langflow at: http://localhost:7860
echo.
echo 👤 Login credentials:
echo   Username: admin
echo   Password: admin123
echo.
echo 📊 Database: 
if exist "docker-compose.yml" (
    docker compose ps postgres >nul 2>&1
    if not errorlevel 1 (
        echo   PostgreSQL ^(with persistent data^)
    ) else (
        echo   SQLite ^(temporary data^)
    )
) else (
    echo   SQLite ^(temporary data^)
)
echo.
echo 🔧 Debug commands:
if exist "docker-compose.yml" (
    docker compose ps postgres >nul 2>&1
    if not errorlevel 1 (
        echo   docker compose logs langflow -f
        echo   docker compose logs postgres -f
        echo   docker compose exec postgres psql -U langflow
    ) else (
        echo   docker logs langflow_sqlite -f
        echo   docker exec -it langflow_sqlite bash
    )
) else (
    echo   docker logs langflow_sqlite -f
    echo   docker exec -it langflow_sqlite bash
)
echo.
pause
