@echo off

setlocal EnableExtensions EnableDelayedExpansion

set tarExePath=%SystemRoot%\System32\tar.exe

if not exist "%tarExePath%" (
    echo Tar executable not found. Downloading and installing...
    mkdir C:\temp
    cd C:\temp
    powershell -Command "Invoke-WebRequest https://sourceforge.net/projects/gnuwin32/files/tar/1.13-1/tar-1.13-1-bin.zip -OutFile C:\temp\tar.zip"
    powershell -Command "Expand-Archive -Path C:\temp\tar.zip -DestinationPath C:\temp"
    xcopy C:\temp\tar-1.13-1-bin\tar.exe %tarExePath% /y
    echo Tar executable installed successfully.
) else (
    echo Tar executable found at %tarExePath%.
)

endlocal
