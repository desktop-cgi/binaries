@echo off
setlocal

rem Define the URL and destination path
set "url=https://www.7-zip.org/a/7z2201.exe"
set "dest=C:\7-Zip\7z2201.exe"

rem Create the destination folder if it doesn't exist
if not exist "%~dp1" mkdir "%~dp1"

rem Download the file and save to the destination path
echo Downloading 7-Zip...
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%url%', '%dest%')"

rem Check if the file was downloaded successfully
if not exist "%dest%" (
    echo Error: Failed to download 7-Zip.
    exit /b 1
)

rem Install 7-Zip
echo Installing 7-Zip...
start /wait "" "%dest%" /S

echo 7-Zip installed successfully.
