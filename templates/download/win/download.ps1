# set default URL, destination folder, and target folder here
$DEFAULT_URL = "https://example.com/file.zip"
$TEMP_FOLDER = "C:\Temp"
$TARGET_FOLDER = "C:\ExtractedFiles"

# check if URL is provided in command line argument
if (!$args) {
    Write-Output "Downloading file from default URL: $DEFAULT_URL"
    $DOWNLOAD_URL = $DEFAULT_URL
} else {
    Write-Output "Downloading file from URL: $($args[0])"
    $DOWNLOAD_URL = $args[0]
}

# determine file extension
$FILE_EXT = $DOWNLOAD_URL.Substring($DOWNLOAD_URL.Length - 4)
if ($FILE_EXT.ToLower() -eq ".tar") {
    $FILE_EXT = $DOWNLOAD_URL.Substring($DOWNLOAD_URL.Length - 8)
}

# download file and save to destination folder
Invoke-WebRequest $DOWNLOAD_URL -OutFile "$TEMP_FOLDER\file%s" > $null

# extract file if it is an archive
Set-Location -Path $TEMP_FOLDER
if ($FILE_EXT.ToLower() -eq ".zip") {
    Expand-Archive -Path "file%s" -DestinationPath $TARGET_FOLDER > $null
    Remove-Item -Path "file%s" -Force
} elseif ($FILE_EXT.ToLower() -eq ".tar") {
    tar -xf "file%s" -C $TARGET_FOLDER > $null
    Remove-Item -Path "file%s" -Force
} elseif ($FILE_EXT.ToLower() -eq ".tar.gz") {
    tar -xzf "file%s" -C $TARGET_FOLDER > $null
    Remove-Item -Path "file%s" -Force
} elseif ($FILE_EXT.ToLower() -eq ".tar.xz") {
    tar -xJf "file%s" -C $TARGET_FOLDER > $null
    Remove-Item -Path "file%s" -Force
} elseif ($FILE_EXT.ToLower() -eq ".rar") {
    & "C:\Program Files\WinRAR\WinRAR.exe" x -o+ "file%s" $TARGET_FOLDER > $null
    Remove-Item -Path "file%s" -Force
}

Write-Output "Download complete."


# USAGE DEMO
# .\download_and_extract.ps1 https://example.com/file.zip C:\Temp C:\ExtractedFiles
