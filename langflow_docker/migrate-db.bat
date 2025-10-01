@echo off
echo =======================================
echo Manual Database Migration
echo =======================================

echo.
echo [1] Checking PostgreSQL status...
docker compose ps postgres
if errorlevel 1 (
    echo Starting PostgreSQL first...
    docker compose up -d postgres
    timeout /t 15 /nobreak >nul
)

echo.
echo [2] Testing database connection...
docker compose exec postgres pg_isready -U langflow
if errorlevel 1 (
    echo ERROR: Cannot connect to database
    echo Make sure PostgreSQL is running: docker compose up -d postgres
    pause
    exit /b 1
)

echo ✓ Database connection OK

echo.
echo [3] Checking if tables exist...
docker compose exec postgres psql -U langflow -d langflow -c "\dt" | findstr "user"
if not errorlevel 1 (
    echo ✓ Tables already exist, migration may not be needed
) else (
    echo ⚠ Tables missing, migration required
)

echo.
echo [4] Running Alembic migration...
docker compose run --rm ^
  -e LANGFLOW_DATABASE_URL=postgresql://langflow:langflow123@postgres:5432/langflow ^
  -e LANGFLOW_CONFIG_DIR=/tmp/langflow ^
  -e HOME=/tmp ^
  --user root ^
  langflow ^
  sh -c "mkdir -p /tmp/langflow && chmod -R 777 /tmp/langflow && echo 'Current directory:' && pwd && echo 'Python path:' && python -c 'import sys; print(sys.path)' && echo 'Running migration...' && python -m alembic upgrade head"

if errorlevel 1 (
    echo.
    echo Migration failed, trying alternative approach...
    echo.
    
    echo [5] Trying langflow migration command...
    docker compose run --rm ^
      -e LANGFLOW_DATABASE_URL=postgresql://langflow:langflow123@postgres:5432/langflow ^
      -e LANGFLOW_CONFIG_DIR=/tmp/langflow ^
      -e HOME=/tmp ^
      --user root ^
      langflow ^
      sh -c "mkdir -p /tmp/langflow && chmod -R 777 /tmp/langflow && langflow migration upgrade"
    
    if errorlevel 1 (
        echo.
        echo [6] Trying manual table creation...
        docker compose run --rm ^
          -e LANGFLOW_DATABASE_URL=postgresql://langflow:langflow123@postgres:5432/langflow ^
          -e LANGFLOW_CONFIG_DIR=/tmp/langflow ^
          -e HOME=/tmp ^
          --user root ^
          langflow ^
          python -c "
from langflow.services.database.models import Base
from langflow.services.database.utils import get_session_sync
from sqlalchemy import create_engine

engine = create_engine('postgresql://langflow:langflow123@postgres:5432/langflow')
Base.metadata.create_all(engine)
print('Tables created successfully')
"
    )
)

echo.
echo [7] Verifying tables were created...
docker compose exec postgres psql -U langflow -d langflow -c "\dt"

echo.
echo =======================================
echo Migration Complete!
echo =======================================
echo.
echo You can now start Langflow:
echo   docker compose up -d langflow
echo.
pause
