# setup.ps1 - one-time setup: download yt-dlp.exe + ffmpeg/ffprobe into this folder.
$ErrorActionPreference = 'Stop'
$dir = $PSScriptRoot
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host ""
Write-Host "Setting up yt-dlp Easy Downloader ..." -ForegroundColor Cyan
Write-Host ""

# 1) yt-dlp.exe
Write-Host "[1/2] Downloading yt-dlp.exe ..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe" -OutFile (Join-Path $dir 'yt-dlp.exe')

# 2) ffmpeg + ffprobe (from yt-dlp's FFmpeg-Builds)
Write-Host "[2/2] Downloading FFmpeg (large file, please wait) ..." -ForegroundColor Cyan
$zip = Join-Path $dir 'ffmpeg.zip'
Invoke-WebRequest -Uri "https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip" -OutFile $zip
$tmp = Join-Path $dir '_ff_tmp'
Expand-Archive -Path $zip -DestinationPath $tmp -Force
Get-ChildItem -Path $tmp -Recurse -Filter '*.exe' |
    Where-Object { $_.Name -in @('ffmpeg.exe','ffprobe.exe') } |
    ForEach-Object { Copy-Item $_.FullName -Destination $dir -Force }
Remove-Item $tmp -Recurse -Force
Remove-Item $zip -Force

Write-Host ""
Write-Host "Done. Executables ready in this folder:" -ForegroundColor Green
Get-ChildItem $dir -Filter '*.exe' | Select-Object Name, Length | Format-Table -AutoSize
Write-Host "You can now double-click Download-Video.bat to start." -ForegroundColor Green
Read-Host "Press Enter to close"
