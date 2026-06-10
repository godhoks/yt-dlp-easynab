# setup.ps1 - one-time setup: download yt-dlp.exe + ffmpeg/ffprobe into this folder.
# Hardened: verifies downloads against the official SHA-256 checksums published
# by each project (fetched live, so they never go stale).
$ErrorActionPreference = 'Stop'
$dir = $PSScriptRoot
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Download a URL and always return its body as text (checksum files come back as
# raw bytes from Invoke-WebRequest because they have no text content-type).
function Get-Text([string]$url) {
    $b = (Invoke-WebRequest -Uri $url -UseBasicParsing).Content
    if ($b -is [byte[]]) { return [System.Text.Encoding]::UTF8.GetString($b) }
    return [string]$b
}

# Find the expected hash for a given filename inside a "<hash>  <name>" sums file.
function Get-ExpectedHash([string]$sumsText, [string]$fileName) {
    foreach ($line in ($sumsText -split "`n")) {
        $t = $line.Trim()
        if (-not $t) { continue }
        $parts = $t -split '\s+', 2
        if ($parts.Count -lt 2) { continue }
        $name = (Split-Path ($parts[1].Trim().TrimStart('*')) -Leaf)
        if ($name -ieq $fileName) { return $parts[0].Trim() }
    }
    return $null
}

# Verify a file against an expected hash. Mismatch = abort. Missing entry = warn only.
function Confirm-Hash([string]$path, [string]$expected, [string]$label) {
    if (-not $expected) {
        Write-Host ("  [!] No official checksum found for $label - skipping verification.") -ForegroundColor Yellow
        return
    }
    $actual = (Get-FileHash -Path $path -Algorithm SHA256).Hash
    if ($actual -ieq $expected) {
        Write-Host ("  [OK] SHA-256 verified: $label") -ForegroundColor Green
    } else {
        Remove-Item $path -Force -ErrorAction SilentlyContinue
        throw "SHA-256 MISMATCH for $label. Download may be corrupt or tampered. Aborted."
    }
}

Write-Host ""
Write-Host "Setting up EasyNab ..." -ForegroundColor Cyan
Write-Host ""

# 1) yt-dlp.exe (+ verify against SHA2-256SUMS)
Write-Host "[1/2] Downloading yt-dlp.exe ..." -ForegroundColor Cyan
$ytExe  = Join-Path $dir 'yt-dlp.exe'
Invoke-WebRequest -Uri "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe" -OutFile $ytExe
$ytSums = Get-Text "https://github.com/yt-dlp/yt-dlp/releases/latest/download/SHA2-256SUMS"
Confirm-Hash $ytExe (Get-ExpectedHash $ytSums 'yt-dlp.exe') 'yt-dlp.exe'

# 2) ffmpeg + ffprobe (verify the zip against checksums.sha256, then extract)
Write-Host "[2/2] Downloading FFmpeg (large file, please wait) ..." -ForegroundColor Cyan
$zipName = 'ffmpeg-master-latest-win64-gpl.zip'
$zip = Join-Path $dir $zipName
Invoke-WebRequest -Uri "https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/$zipName" -OutFile $zip
$ffSums = Get-Text "https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/checksums.sha256"
Confirm-Hash $zip (Get-ExpectedHash $ffSums $zipName) $zipName

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
