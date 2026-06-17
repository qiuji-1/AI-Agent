@echo off
chcp 65001 >nul 2>&1
title Q-AI-Agent Stop
color 0C

echo ======================================
echo    Q-AI-Agent Stop Services
echo ======================================
echo.

echo [1/2] Stopping backend service...
taskkill /F /FI "WINDOWTITLE eq Backend*" > nul 2>&1
taskkill /F /IM java.exe > nul 2>&1
echo [OK] Backend stopped

echo [2/2] Stopping frontend service...
taskkill /F /FI "WINDOWTITLE eq Frontend*" > nul 2>&1
taskkill /F /IM node.exe > nul 2>&1
echo [OK] Frontend stopped

echo.
echo ======================================
echo    All services stopped!
echo ======================================
pause