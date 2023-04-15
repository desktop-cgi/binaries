@echo off
setlocal enabledelayedexpansion

if "%1" == "" (
    echo Usage: %0 <config_file>
    exit /b 1
)

set "config_file=%~1"

if not exist "%config_file%" (
    echo Config file not found: %config_file%
    exit /b 1
)

set "downloadkey="
set "url="
set "tmp="
set "dest="

for /f "usebackq tokens=1,2 delims=:{}" %%a in ("%config_file%") do (
    if "%%a"=="downloadkey" (
        set "downloadkey=%%b"
    ) else if "%%a"=="url" (
        set "url=%%b"
    ) else if "%%a"=="tmp" (
        set "tmp=%%b"
    ) else if "%%a"=="dest" (
        set "dest=%%b"
    )
)

if "%downloadkey%" == "" (
    echo Invalid config file: downloadkey is missing.
    exit /b 1
)

if "%url%" == "" (
    echo Invalid config file: url is missing.
    exit /b 1
)

if "%tmp%" == "" (
    echo Invalid config file: tmp is missing.
    exit /b 1
)

if "%dest%" == "" (
    echo Invalid config file: dest is missing.
    exit /b 1
)

set "temp_folder=%tmp%\%downloadkey%"
set "temp_file=%temp_folder%\%downloadkey%.zip"

if not exist "%temp_folder%" mkdir "%temp_folder%"

echo Downloading %url% and extracting to %temp_file% to destination to %dest%...


if not exist "%temp_file%" (
    echo Download failed and cannot be done: %temp_file% not found.
    exit /b 1
)

if not exist "%dest%" (
    echo Extract failed and cannot be done: %dest% not found.
    exit /b 1
)

call download.bat "%url%" "%temp_folder%" "%temp_file%"


echo Done.


@REM download_main.bat config.json
