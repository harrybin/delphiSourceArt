@echo off
REM Build DelphiSourceArt
echo Building DelphiSourceArt...

REM Create output directories if they don't exist
if not exist "bin" mkdir bin
if not exist "dcu" mkdir dcu

REM Compile the project
dcc32 DelphiSourceArt.dpr -B -E.\bin -N.\dcu

REM Check result
if %ERRORLEVEL% EQU 0 (
    echo.
    echo Build successful! EXE created in .\bin\DelphiSourceArt.exe
) else (
    echo.
    echo Build failed with error code %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)
