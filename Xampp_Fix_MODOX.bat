@echo off
:: Ensure the script runs as Administrator
:: If not, re-run as Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting Administrator Privileges...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~s0' -Verb RunAs"
    exit
)

echo Welcome to XAMPP Server Fixer by MODOX

echo Finding XAMPP directory...
:: Automatically find XAMPP installation directory
set "XAMPP_DIR=C:\xampp"
if exist "%ProgramFiles%\XAMPP" set "XAMPP_DIR=%ProgramFiles%\XAMPP"
if exist "%ProgramFiles(x86)%\XAMPP" set "XAMPP_DIR=%ProgramFiles(x86)%\XAMPP"
echo XAMPP found at %XAMPP_DIR%

cd /d %XAMPP_DIR%

echo Checking Port and PID...
:: Check and free ports 80 and 443 (Apache) and 3306 (MySQL)
for %%P in (80 443 3306) do (
    for /f "tokens=5" %%A in ('netstat -ano ^| findstr :%%P') do (
        taskkill /PID %%A /F >nul 2>&1
    )
)

echo Cleaning up, Please Wait...

:: Stop Apache and MySQL
echo Stopping Apache Server...
taskkill /IM httpd.exe /F >nul 2>&1
echo Stopping MySQL Server...
taskkill /IM mysqld.exe /F >nul 2>&1
echo Stop Server...

:: Start Apache using XAMPP control
echo Starting Apache Server...
start /min %XAMPP_DIR%\xampp-control.exe --start Apache
timeout /t 5 >nul

tasklist | findstr /i "httpd.exe" >nul
if %errorLevel% neq 0 (
    echo Apache Server Start Failed. Please Start Manually.
) else (
    echo Apache Server Started Successfully.
)

:: Start MySQL as a Windows service
echo Starting MySQL Server...
sc query mysql | findstr /i "RUNNING" >nul
if %errorLevel% neq 0 (
    sc start mysql >nul 2>&1
    timeout /t 5 >nul
)

tasklist | findstr /i "mysqld.exe" >nul
if %errorLevel% neq 0 (
    echo MySQL Server Start Failed. Please Start Manually.
) else (
    echo MySQL Server Started Successfully.
)

echo.
echo Press any key to exit...
pause >nul
exit
