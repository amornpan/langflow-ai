@echo off
echo ================================
echo  📋 All Available Commands
echo ================================

echo.
echo 🚀 EASY START (Recommended):
echo   start.bat              - Simple Langflow (SQLite, no setup)
echo   compose-start.bat      - Full setup (PostgreSQL + Langflow)
echo.
echo 🔧 MANAGEMENT:
echo   stop.bat               - Stop simple Langflow
echo   status.bat             - Check status
echo   cleanup.bat            - Remove simple Langflow
echo.
echo 🐳 DOCKER COMPOSE:
echo   docker compose up -d              - Start all services
echo   docker compose down               - Stop all services
echo   docker compose logs langflow -f   - Follow logs
echo   docker compose ps                 - Check status
echo   docker compose restart langflow   - Restart Langflow
echo.
echo 🔍 TROUBLESHOOTING:
echo   diagnose.bat           - Run diagnostics
echo   check-port.bat         - Check what's using ports
echo   cleanup-and-start.bat  - Clean everything and restart
echo   clear-cache.bat        - Browser cache instructions
echo.
echo 💡 WHICH ONE TO USE?
echo.
echo ✅ For quick testing:
echo   start.bat
echo.
echo ✅ For development/production:
echo   compose-start.bat
echo.
echo ✅ If having problems:
echo   cleanup-and-start.bat
echo.
pause
