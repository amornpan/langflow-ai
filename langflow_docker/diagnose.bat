@echo off
echo ================================
echo  🔍 Langflow Diagnostics
echo ================================

echo.
echo [1] Container Status:
docker ps --filter name=langflow_easy --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo.
echo [2] Port Check:
echo Checking port 7860...
netstat -ano | findstr ":7860" | findstr "LISTENING"

echo Checking port 8000...
netstat -ano | findstr ":8000" | findstr "LISTENING"

echo.
echo [3] Container Logs (last 20 lines):
docker logs langflow_easy --tail=20 2>nul

echo.
echo [4] Testing Endpoints:
echo.
echo Testing main page...
curl -s -w "Status: %%{http_code}\n" -o nul http://localhost:7860

echo Testing health endpoint...
curl -s -w "Status: %%{http_code}\n" -o nul http://localhost:7860/health

echo Testing SSE endpoint...
curl -s -w "Status: %%{http_code}\n" -o nul http://localhost:7860/sse

echo Testing API endpoint...
curl -s -w "Status: %%{http_code}\n" -o nul http://localhost:7860/api/v1/auto_login

echo.
echo [5] Environment Variables:
docker exec langflow_easy env | findstr LANGFLOW

echo.
echo ================================
echo 📋 Summary:
echo ================================
echo.
echo If all tests show "Status: 200" or "Status: 404":
echo ✅ Server is working, likely a browser cache issue
echo → Run: clear-cache.bat
echo.
echo If tests show connection errors:
echo ❌ Server issue
echo → Run: fix-sse.bat
echo.
pause
