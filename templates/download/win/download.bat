@echo off

rem Usage: download_extract.bat <compressiontype> <url> <tmp> <target>
rem Arguments:
rem - <compressiontype>: The compression type of the downloaded file, e.g. zip, tar, tar.xz, tar.gz, rar.
rem - <url>: The URL of the file to download.
rem - <tmp>: The tmp folder to save the downloaded file.
rem - <target>: The target folder to extract the downloaded file.
rem Example: download_extract.bat tar.gz https://example.com/file.tar.gz C:\temp\ ExtractedFiles

set DEFAULT_URL=https://example.com/file.zip
set TEMP_FOLDER=C:\temp\
set TARGET_FOLDER=ExtractedFiles

if "%1"=="" (
    echo Usage: download_extract.bat ^<compressiontype^> ^<url^> ^<tmp^> ^<target^>
    exit /b 1
)

if "%2"=="" (
    echo Usage: download_extract.bat ^<compressiontype^> ^<url^> ^<tmp^> ^<target^>
    exit /b 1
)

if "%3"=="" (
    echo Usage: download_extract.bat ^<compressiontype^> ^<url^> ^<tmp^> ^<target^>
    exit /b 1
)

if "%4"=="" (
    echo Usage: download_extract.bat ^<compressiontype^> ^<url^> ^<tmp^> ^<target^>
    exit /b 1
)

set COMPRESSION_TYPE=%1
set URL=%2
set TEMP_FOLDER=%3
set TARGET_FOLDER=%4

if not exist "%TEMP_FOLDER%" mkdir "%TEMP_FOLDER%"
if not exist "%TARGET_FOLDER%" mkdir "%TARGET_FOLDER%"

setlocal

set "wget_cmd=where wget"
set "curl_cmd=where curl"

rem Check if wget or curl is already installed
for /f "usebackq delims=" %%i in (`%wget_cmd% 2^>nul`) do set "wget_path=%%i"
for /f "usebackq delims=" %%i in (`%curl_cmd% 2^>nul`) do set "curl_path=%%i"


for /f "delims=." %%i in ("%URL%") do set FILE_EXT=%%~xi

REM Check if Invoke-WebRequest is installed
where powershell >nul 2>nul
if %errorlevel% == 0 (
    set hasInvokeWebRequest=true
) else (
    set hasInvokeWebRequest=false
)


if not exist "%TEMP_FOLDER%\file%s" (
    if defined curl (
        curl -fsSL "%URL%" -o "%TEMP_FOLDER%\file%s"
    ) else if defined wget (
        wget -q "%URL%" -P "%TEMP_FOLDER%" -O "%TEMP_FOLDER%\file%s"
    ) else if %hasInvokeWebRequest% == true (
        @REM wget -q "%URL%" -P "%TEMP_FOLDER%" -O "%TEMP_FOLDER%\file%s"
        powershell -Command "Invoke-WebRequest "%URL%" -OutFile '%TEMP_FOLDER%\file%s'"
    ) else (
        echo Error: neither curl nor wget nor powershell Invoke-WebRequest is installed
        exit /b 1
    )
)

if %errorlevel% neq 0 (
    echo Error: Download failed
    del /q "%TEMP_FOLDER%\file%s"
    exit /b 1
)


:: extract file if it is an archive
cd "%TEMP_FOLDER%"
if "%COMPRESSION_TYPE%" == "zip" if "%FILE_EXT%" == "zip" (
    powershell -nologo -noprofile -command "Expand-Archive -Path file%s -DestinationPath %TARGET_FOLDER%"
    del /f "file%s"
) else if "%COMPRESSION_TYPE%" == "tar" if "%FILE_EXT%" == "tar" (
    tar -xf "file%s" -C "%TARGET_FOLDER%"
    del /f "file%s"
) else if "%COMPRESSION_TYPE%" == "tar.xz" if "%FILE_EXT%" == "tar.xz" (
    tar -xJf "file%s" -C "%TARGET_FOLDER%"
    del /f "file%s"
) else if "%COMPRESSION_TYPE%" == "tar.gz" if "%FILE_EXT%" == "tar.gz" (
    tar -xzf "file%s" -C "%TARGET_FOLDER%"
    del /f "file%s"
) else if "%COMPRESSION_TYPE%" == "rar" if "%FILE_EXT%" == "rar" (
    "C:\Program Files\WinRAR\WinRAR.exe" x -o+ "file%s" "%TARGET_FOLDER%"
    del /f "file%s"
) else (
    echo Error: Compression type does not match file extension.
    del /f "file%s"
    exit /b 1
)

if %errorlevel% neq 0 (
    echo Error: Extraction failed
    exit /b 1
)

echo Download complete.


@REM @REM USAGE DEMO
@REM download_and_extract.bat https://example.com/file.zip "C:\Downloads" "C:\ExtractedFiles"
