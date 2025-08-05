@echo off
echo ================================
echo  🌐 Browser Cache Clear Guide
echo ================================

echo.
echo The SSE error is often caused by browser cache.
echo Please follow these steps:
echo.
echo 📌 For Chrome/Edge:
echo 1. Press Ctrl + Shift + Delete
echo 2. Select "All time" 
echo 3. Check "Cached images and files"
echo 4. Check "Cookies and other site data"
echo 5. Click "Delete data"
echo.
echo 📌 For Firefox:
echo 1. Press Ctrl + Shift + Delete
echo 2. Select "Everything"
echo 3. Check "Cache" and "Cookies"
echo 4. Click "Clear Now"
echo.
echo 📌 Or use Incognito/Private mode:
echo - Chrome: Ctrl + Shift + N
echo - Firefox: Ctrl + Shift + P
echo - Edge: Ctrl + Shift + N
echo.

set /p ready="Ready to continue? Press Enter..."

echo.
echo Opening Langflow in default browser...
start http://localhost:7860

echo.
echo 💡 If problems persist:
echo 1. Close ALL browser windows
echo 2. Restart browser completely
echo 3. Try different browser
echo 4. Check: docker logs langflow_easy -f
echo.
pause
