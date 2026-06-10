# Changelog

All notable changes to EasyNab are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-06-10

### Security
- `setup.ps1` now verifies every download against the **official SHA-256 checksums**
  published by yt-dlp (`SHA2-256SUMS`) and FFmpeg-Builds (`checksums.sha256`).
  Checksums are fetched live, so they never go stale; a mismatch aborts setup.

## [1.0.0] - 2026-06-10

First public release.

### Added
- Double-click downloader (`Download-Video.bat`) — no command line needed
- Quality menu: Best / 1080p / 720p / 480p / 360p / Audio-only (MP3)
- Always outputs a clean **MP4** (or **MP3** for audio)
- Playlist-aware: choose the whole playlist or just one video
- Type `B` to go back a step, `Q` to quit
- Input validation that rejects invalid choices instead of guessing
- `setup.ps1` that automatically downloads `yt-dlp.exe`, `ffmpeg.exe`, and `ffprobe.exe`

[1.0.1]: https://github.com/godhoks/yt-dlp-easynab/releases/tag/v1.0.1
[1.0.0]: https://github.com/godhoks/yt-dlp-easynab/releases/tag/v1.0.0
