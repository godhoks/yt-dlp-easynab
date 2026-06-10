# EasyNab

![version](https://img.shields.io/badge/version-1.0.0-blue) ![platform](https://img.shields.io/badge/platform-Windows-blue) ![license](https://img.shields.io/badge/license-MIT-green)

> **Easy + nab** — a simple **double-click** video downloader for Windows.

Powered by [yt-dlp](https://github.com/yt-dlp/yt-dlp) and [FFmpeg](https://ffmpeg.org/).
Paste a URL, pick a quality, done — no command line needed.

## Features
- Double-click to run — no typing commands
- Quality menu: **Best / 1080p / 720p / 480p / 360p / Audio-only (MP3)**
- Always outputs a clean **.mp4** (or **.mp3** for audio)
- Playlist-aware: choose the whole playlist or just one video
- Type **B** to go back a step, **Q** to quit
- Rejects invalid input instead of guessing

## Requirements
- Windows 10 / 11
- Windows PowerShell (built in)
- Internet connection

## Setup (one time)
EasyNab relies on three small programs: `yt-dlp.exe`, `ffmpeg.exe`, and `ffprobe.exe`.
**You do NOT install them manually — `setup.ps1` downloads all three for you, automatically.**

1. Get the code: click the green **Code** button → **Download ZIP**, then unzip
   (or `git clone` this repo).
2. Right-click **`setup.ps1`** → **Run with PowerShell**, then wait.
   It automatically downloads `yt-dlp.exe`, `ffmpeg.exe`, and `ffprobe.exe` into
   the same folder. When it prints **Done**, you're ready.
   - If Windows blocks the script, open a terminal in the folder and run:
     ```powershell
     powershell -ExecutionPolicy Bypass -File .\setup.ps1
     ```

You only do this once. After setup, just use `Download-Video.bat` from now on.

> 🔒 `setup.ps1` verifies every download against the official **SHA-256 checksums**
> published by yt-dlp and FFmpeg-Builds. If a file is corrupt or tampered with, setup stops.

## Usage
Double-click **`Download-Video.bat`**, then follow the prompts:
1. Paste the video URL
2. If it's a playlist → choose whole list / this video only / cancel
3. Pick a quality number
4. Files save to `%USERPROFILE%\Downloads\Video`
   (if that folder doesn't exist, it asks where to save)

## Supported sites
yt-dlp supports ~1800 sites (YouTube, Vimeo, X/Twitter, TikTok, Instagram,
Bilibili, SoundCloud, Dailymotion, and more).
It does **not** work on DRM-protected services such as **Netflix, Disney+,
Prime Video, Apple TV+**.

Check whether a site is supported:
```powershell
.\yt-dlp.exe --list-extractors
```

## Disclaimer
For **personal and lawful use only**. Respect each website's Terms of Service
and applicable copyright law. Do not download content you do not have the right
to download. The author assumes no responsibility for misuse.

## Credits & License
- Download engine: [yt-dlp](https://github.com/yt-dlp/yt-dlp) (Unlicense)
- Media processing: [FFmpeg](https://ffmpeg.org/) (GPL/LGPL) — downloaded separately, **not bundled**
- These scripts: **MIT License** (see [LICENSE](LICENSE))
