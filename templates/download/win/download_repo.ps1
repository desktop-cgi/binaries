$ErrorActionPreference = "Stop"

if ($args.Count -ne 1) {
    Write-Host "Usage: $PSCommandPath <config_file>"
    exit 1
}

$config_file = $args[0]

if (-not (Test-Path $config_file -PathType Leaf)) {
    Write-Host "Config file not found: $config_file"
    exit 1
}

$json = Get-Content $config_file | ConvertFrom-Json

if (-not ($json.downloadkey -and $json.downloadkey.url -and $json.downloadkey.tmp -and $json.downloadkey.dest)) {
    Write-Host "Invalid config file: downloadkey, url, tmp, and dest are required properties."
    exit 1
}

$temp_folder = Join-Path $json.downloadkey.tmp $json.downloadkey.downloadkey
$temp_file = Join-Path $temp_folder "$($json.downloadkey.downloadkey).zip"

if (-not (Test-Path $temp_folder)) {
    New-Item -ItemType Directory -Path $temp_folder | Out-Null
}

Write-Host "Downloading $($json.downloadkey.url) to $temp_file..."

& download.bat $json.downloadkey.url $temp_folder $temp_file

if (-not (Test-Path $temp_file)) {
    Write-Host "Download failed: $temp_file not found."
    exit 1
}

Write-Host "Extracting $temp_file to $($json.downloadkey.dest)..."

& extract.bat $temp_file $json.downloadkey.dest

if (-not (Test-Path $json.downloadkey.dest)) {
    Write-Host "Extract failed: $($json.downloadkey.dest) not found."
    exit 1
}

Write-Host "Done."


# download_main.ps1 config.json
