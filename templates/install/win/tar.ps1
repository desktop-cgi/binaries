$tarExePath = "$env:SystemRoot\System32\tar.exe"

if (-not (Test-Path $tarExePath)) {
    Write-Output "Tar executable not found. Downloading and installing..."
    $tempFolder = New-Item -ItemType Directory -Path "$env:TEMP\install-tar"
    Invoke-WebRequest https://sourceforge.net/projects/gnuwin32/files/tar/1.13-1/tar-1.13-1-bin.zip -OutFile "$tempFolder\tar.zip"
    Expand-Archive -Path "$tempFolder\tar.zip" -DestinationPath $tempFolder
    Copy-Item -Path "$tempFolder\tar-1.13-1-bin\tar.exe" -Destination $tarExePath
    Write-Output "Tar executable installed successfully."
} else {
    Write-Output "Tar executable found at $tarExePath."
}
