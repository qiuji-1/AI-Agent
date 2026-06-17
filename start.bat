@echo off
chcp 65001 >nul 2>&1
title Q-AI-Agent Start
color 0A

echo ======================================
echo    Q-AI-Agent Quick Start
echo ======================================
echo.

set "BD=a:\Workspace\AiAgent\q-ai-agent"
set "FD=a:\Workspace\AiAgent\qiu-agent-frontend"
set "BP=8123"
set "FP=5173"

echo [1/4] Checking environment...

where mvn >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Maven not found! Please install Maven.
    pause
    exit /b 1
)
echo [OK] Maven installed

where npm >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js not found! Please install Node.js.
    pause
    exit /b 1
)
echo [OK] Node.js installed

if not exist "%BD%\pom.xml" (
    echo [ERROR] Backend project not found: %BD%
    pause
    exit /b 1
)
echo [OK] Backend project exists

if not exist "%FD%\package.json" (
    echo [ERROR] Frontend project not found: %FD%
    pause
    exit /b 1
)
echo [OK] Frontend project exists

echo.
echo [2/4] Starting backend service...
cd /d "%BD%"
start "Backend (port:%BP%)" cmd /k "mvn spring-boot:run"
echo [OK] Backend started (new window)

echo.
echo [3/4] Starting frontend service...
cd /d "%FD%"
start "Frontend (port:%FP%)" cmd /k "npm run dev"
echo [OK] Frontend started (new window)

echo.
echo [4/4] Waiting for services...

set "MW=30"
set "WC=0"
:WL
timeout /t 2 /nobreak >nul
set /a WC+=2
echo Waiting %WC% seconds...

powershell -Command "try { $r = Invoke-WebRequest -Uri 'http://localhost:%BP%/api/health' -UseBasicParsing -TimeoutSec 2; if ($r.StatusCode -eq 200) { exit 0 } } catch { exit 1 }"
if %errorlevel% equ 0 (
    echo [OK] Backend ready!
    goto SR
)

if %WC% geq %MW% (
    echo [WARN] Timeout, service may not be ready
    goto SR
)

goto WL

:SR
echo.
echo Opening browser...
start http://localhost:%FP%

echo.
echo ======================================
echo    Services Started!
echo ======================================
echo  Backend: http://localhost:%BP%/api
echo  Frontend: http://localhost:%FP%
echo ======================================
echo.
echo Tips:
echo   - Backend runs in window "Backend"
echo   - Frontend runs in window "Frontend"
echo   - Close windows to stop services
echo   - Double-click stop.bat to stop all
echo.
echo Press any key to close...
pause >nul