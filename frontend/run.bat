@echo off
echo ========================================
echo Flutter Web Build Menu
echo ========================================
echo.
echo Select build type:
echo   1. Web Dev (development mode)
echo   2. Web Release Dev (release with dev API)
echo   3. Web Release Prod (release with prod API)
echo.
set /p choice="Enter your choice (1-3): "

if "%choice%"=="1" goto web_dev
if "%choice%"=="2" goto web_release_dev
if "%choice%"=="3" goto web_release_prod

echo Invalid choice!
pause
exit /b 1

:web_dev
echo.
echo ========================================
echo Building Flutter Web (Development Mode)
echo ========================================
echo.
cd /d "%~dp0"
flutter run -d chrome --web-port=8080
goto end

:web_release_dev
echo.
echo ========================================
echo Running Flutter Web (Release - Dev API)
echo ========================================
echo.
cd /d "%~dp0"
flutter run -d chrome --release --dart-define=API_URL=http://localhost:8000 --web-port=8080
goto end

:web_release_prod
echo.
echo ========================================
echo Building Flutter Web (Release - Prod API)
echo ========================================
echo.
cd /d "%~dp0"
flutter build web --release --dart-define=API_URL=https://kinrai-d-production.up.railway.app
if %ERRORLEVEL% NEQ 0 goto build_failed
goto build_success

:build_failed
echo.
echo ========================================
echo BUILD FAILED!
echo ========================================
pause
exit /b %ERRORLEVEL%

:build_success
echo.
echo ========================================
echo BUILD SUCCESSFUL!
echo ========================================
echo.
echo Output directory: %CD%\build\web
echo.
echo To deploy to Netlify, run:
echo   netlify deploy --prod --dir=build/web
echo.
goto end

:end
pause
