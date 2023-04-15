@echo off

setlocal

REM Check if curl is already installed
where curl >nul 2>nul
if %errorlevel% == 0 (
    set downloader=curl
) else (
    REM Check if wget is installed
    where wget >nul 2>nul
    if %errorlevel% == 0 (
        set downloader=wget
    ) else (
        REM Install curl
        powershell -Command "Invoke-WebRequest https://curl.se/windows/dl-7.80.0/curl-7.80.0-win64-mingw.zip -OutFile curl.zip"
        powershell -Command "Expand-Archive -Path curl.zip -DestinationPath ."
        set downloader=curl
    )
)

REM Download and install tar executable
%downloader% -O tar.zip https://sourceforge.net/projects/gnuwin32/files/tar/1.13-1/tar-1.13-1-bin.zip/download
powershell -Command "Expand-Archive -Path 'C:\Users\GB\Documents\projects\allprojects\desktopcgi\desktop-cgi\binaries\templates\download\win\tar.zip' -DestinationPath ."

REM Add tar executable to PATH
set PATH=%CD%\bin;%PATH%

REM Clean up
del tar.zip
if "%downloader%" == "curl" (
    del curl.zip
    move .\curl-7.80.0-win64-mingw\bin\curl.exe .\
    rmdir /s /q curl-7.80.0-win64-mingw
)

echo Installation complete.
