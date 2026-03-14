@echo off
setlocal enabledelayedexpansion

REM ===== SCRIPT LOCATION =====
set SCRIPT_DIR=%~dp0

REM ===== CONFIG FILE =====
set MAPFILE=%SCRIPT_DIR%sync_map.txt

REM ===== LOG DIRECTORY =====
set LOGBASE=%SCRIPT_DIR%logs
if not exist "%LOGBASE%" mkdir "%LOGBASE%"

REM ===== DATE =====
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set TODAY=%%i

set COUNT=1
:findlog
    set LOG=%LOGBASE%\%TODAY%-%COUNT%.log
    if exist "%LOG%" (
        set /a COUNT+=1
        goto findlog
    )

set JOBS=0
set FAILED=0

echo ================================================= >> "%LOG%"
echo Sync started %DATE% %TIME% >> "%LOG%"
echo ================================================= >> "%LOG%"

REM ===== READ CONFIG FILE =====
for /f "tokens=1,* delims==" %%A in ('type "%MAPFILE%" ^| findstr /v /r "^#"') do (
    if not "%%A"=="" (
        if "%%A"=="NASROOT" (
            set NASROOT=%%B
        ) else (
            for /f "tokens=1,2 delims=|" %%X in ("%%A") do (
                if not "%%X"=="" call :sync "%%X" "%%Y"
            )
        )
    )
)

echo.
echo =========================================
echo Sync summary
echo =========================================
echo Jobs executed: %JOBS%
echo Jobs failed:   %FAILED%

echo ========================================= >> "%LOG%"
echo Sync summary >> "%LOG%"
echo Jobs executed: %JOBS% >> "%LOG%"
echo Jobs failed:   %FAILED% >> "%LOG%"

if %FAILED% GTR 0 exit /b 1
exit /b 0

REM ===== SYNC FUNCTION =====
:sync
    set SRC=%~1
    set DEST=%NASROOT%\%~2

    set /a JOBS+=1

    echo -------------------------------------------------
    echo Syncing !SRC!
    echo Destination !DEST!
    echo.

    echo ------------------------------------------------- >> "%LOG%"
    echo Syncing !SRC! >> "%LOG%"
    echo Destination !DEST! >> "%LOG%"

    robocopy "!SRC!" "!DEST!" ^
        /E ^
        /XO ^
        /FFT ^
        /MT:8 ^
        /R:5 ^
        /W:5 ^
        /ETA ^
        /TEE ^
        /DCOPY:DAT ^
        /LOG+:"%LOG%"

    if errorlevel 8 (
        echo ERROR syncing !SRC!
        echo ERROR syncing !SRC! >> "%LOG%"
        set /a FAILED+=1
    )

    goto :eof
