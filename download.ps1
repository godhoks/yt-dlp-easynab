# yt-dlp interactive downloader (English UI)
# Type B at most prompts to go back one step, Q at the URL prompt to quit.
$ErrorActionPreference = 'Stop'

$root  = $PSScriptRoot
$ytdlp = Join-Path $root 'yt-dlp.exe'

if (-not (Test-Path $ytdlp)) {
    Write-Host "ERROR: yt-dlp.exe not found in $root" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

$defaultDir = Join-Path $env:USERPROFILE 'Downloads\Video'

Write-Host ""
Write-Host "==============================" -ForegroundColor Cyan
Write-Host "   EasyNab   v1.0.0"           -ForegroundColor Cyan
Write-Host "   Video Downloader for Windows" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan

# Shared state
$url        = $null
$isPlayUrl  = $false   # URL looks like a playlist
$plFlag     = @()      # --yes-playlist / --no-playlist
$fmtArgs    = @()      # format selection args
$outDir     = $null

$step = 'url'
while ($step -ne 'done') {
    switch ($step) {

        'url' {
            Write-Host ""
            $in = Read-Host "Paste video URL  (Q = quit)"
            $c = $in.Trim()
            if ($c -ieq 'Q') { Write-Host "Bye."; exit }
            if ([string]::IsNullOrWhiteSpace($c)) { Write-Host "Empty URL, try again." -ForegroundColor Yellow; break }
            $url = $c
            if ($url -match 'list=' -or $url -match '/playlist') { $isPlayUrl = $true; $step = 'playlist' }
            else { $isPlayUrl = $false; $plFlag = @(); $step = 'quality' }
        }

        'playlist' {
            Write-Host ""
            Write-Host "This URL looks like a PLAYLIST." -ForegroundColor Yellow
            Write-Host "    1) Download the WHOLE playlist"
            Write-Host "    2) Download only THIS one video   [default]"
            Write-Host "    3) Cancel"
            $in = (Read-Host "Enter 1-3  (B = back)").Trim()
            switch -Regex ($in) {
                '^[Bb]$'  { $step = 'url' }
                '^1$'     { $plFlag = @('--yes-playlist'); $step = 'quality' }
                '^(2|)$'  { $plFlag = @('--no-playlist'); $step = 'quality' }
                '^3$'     { Write-Host "Cancelled."; Read-Host "Press Enter to close"; exit }
                default   { Write-Host "Invalid choice. Please enter 1, 2, 3, or B." -ForegroundColor Yellow }
            }
        }

        'quality' {
            Write-Host ""
            Write-Host "Choose quality  (picks that resolution or the best below it):"
            Write-Host "    1) Best available   [default]"
            Write-Host "    2) 1080p"
            Write-Host "    3) 720p"
            Write-Host "    4) 480p"
            Write-Host "    5) 360p"
            Write-Host "    6) Audio only (MP3)"
            $in = (Read-Host "Enter 1-6  (B = back)").Trim()
            $mp4 = @('--merge-output-format', 'mp4')
            switch -Regex ($in) {
                '^[Bb]$' { if ($isPlayUrl) { $step = 'playlist' } else { $step = 'url' } }
                '^2$'    { $fmtArgs = @('-f','bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/bestvideo[height<=1080]+bestaudio/best[height<=1080]') + $mp4; $step = 'folder' }
                '^3$'    { $fmtArgs = @('-f','bestvideo[height<=720][ext=mp4]+bestaudio[ext=m4a]/bestvideo[height<=720]+bestaudio/best[height<=720]') + $mp4; $step = 'folder' }
                '^4$'    { $fmtArgs = @('-f','bestvideo[height<=480][ext=mp4]+bestaudio[ext=m4a]/bestvideo[height<=480]+bestaudio/best[height<=480]') + $mp4; $step = 'folder' }
                '^5$'    { $fmtArgs = @('-f','bestvideo[height<=360][ext=mp4]+bestaudio[ext=m4a]/bestvideo[height<=360]+bestaudio/best[height<=360]') + $mp4; $step = 'folder' }
                '^6$'    { $fmtArgs = @('-x','--audio-format','mp3'); $step = 'folder' }
                '^(1|)$' { $fmtArgs = @('-f','bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio/best') + $mp4; $step = 'folder' }
                default  { Write-Host "Invalid choice. Please enter 1-6 or B." -ForegroundColor Yellow }
            }
        }

        'folder' {
            if (Test-Path -LiteralPath $defaultDir) { $outDir = $defaultDir; $step = 'done'; break }
            Write-Host ""
            Write-Host "Default folder does not exist:" -ForegroundColor Yellow
            Write-Host "    $defaultDir"
            $in = (Read-Host "Press Enter to create it / type another path / B = back").Trim()
            if ($in -imatch '^[Bb]$') { $step = 'quality'; break }
            if ([string]::IsNullOrWhiteSpace($in)) { $outDir = $defaultDir } else { $outDir = $in.Trim('"') }
            New-Item -ItemType Directory -Path $outDir -Force | Out-Null
            $step = 'done'
        }
    }
}

# --- Download ---
$outTpl = Join-Path $outDir '%(title)s.%(ext)s'
$args   = @('--ffmpeg-location', $root, '-o', $outTpl) + $plFlag + $fmtArgs

Write-Host ""
Write-Host "Downloading to: $outDir" -ForegroundColor Green
Write-Host ""
& $ytdlp @args $url

Write-Host ""
if ($LASTEXITCODE -eq 0) {
    Write-Host "DONE. Saved to: $outDir" -ForegroundColor Green
} else {
    Write-Host "Finished with errors (exit code $LASTEXITCODE)." -ForegroundColor Yellow
}
Read-Host "Press Enter to close"
