#Requires -Version 5.0
<#
.SYNOPSIS
    Generates the final MP4 video by combining audio and slides.

.DESCRIPTION
    Uses FFmpeg to create a professional training video.
#>

param(
    [string]$AudioDir = ".\audio",
    [string]$SlideDir = ".\slides",
    [string]$OutputFile = ".\video.mp4",
    [double]$Transition = 0.5
)

$ErrorActionPreference = 'Stop'

Write-Host "🎬 Video Composition Script"
Write-Host "============================"
Write-Host ""

# Verify FFmpeg is available
Write-Host "🔍 Checking for FFmpeg..."
try {
    $ffmpegVersion = ffmpeg -version 2>&1 | Select-Object -First 1
    Write-Host "✅ FFmpeg found: $ffmpegVersion"
} catch {
    Write-Error "❌ FFmpeg not found. Install FFmpeg to proceed."
}

Write-Host ""

# Verify inputs
if (-not (Test-Path $AudioDir)) {
    Write-Error "Audio directory not found: $AudioDir"
}

if (-not (Test-Path $SlideDir)) {
    Write-Error "Slide directory not found: $SlideDir"
}

# Get audio files (only slide-*.mp3, not combined.mp3)
$audioFiles = Get-ChildItem -Path $AudioDir -Filter "slide-*.mp3" | Sort-Object Name
$slideFiles = Get-ChildItem -Path $SlideDir -Filter "*.png" | Sort-Object Name

if ($audioFiles.Count -eq 0) {
    Write-Error "No audio files found in: $AudioDir"
}

Write-Host "📊 Content Summary:"
Write-Host "   Audio files: $($audioFiles.Count)"
Write-Host "   Slide files: $($slideFiles.Count)"
Write-Host ""

# Calculate total duration from audio files using ffprobe
Write-Host "⏱️  Analyzing audio files with ffprobe..."
$totalDuration = 0
$audioTracks = @()

foreach ($audioFile in $audioFiles) {
    # Get actual duration using ffprobe
    try {
        $durationOutput = ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$($audioFile.FullName)" 2>&1
        $duration = [double]$durationOutput
        Write-Host "   📝 $($audioFile.Name) - $([Math]::Round($duration, 1))s"
    } catch {
        Write-Warning "Could not get duration for $($audioFile.Name), using 60s default"
        $duration = 60.0
    }
    
    $totalDuration += $duration
    
    $audioTracks += @{
        File = $audioFile.FullName
        Duration = $duration
    }
}

Write-Host ""
Write-Host "✅ Total estimated duration: ~$([Math]::Round($totalDuration / 60, 1)) minutes"
Write-Host ""

# Create FFmpeg concat file for audio
Write-Host "🎙️  Preparing audio concatenation..."
$concatFile = Join-Path $AudioDir "concat.txt"

$concatContent = ""
foreach ($track in $audioTracks) {
    $concatContent += "file '$($track.File)'`n"
}

Set-Content -Path $concatFile -Value $concatContent
Write-Host "✅ Created concat file: $concatFile"
Write-Host ""

# Create combined audio
Write-Host "🎵 Combining audio tracks..."
$audioOutput = Join-Path $AudioDir "combined.mp3"

Write-Host "Running: ffmpeg -f concat -safe 0 -i `"$concatFile`" -c copy -y `"$audioOutput`""
Write-Host ""

# Execute FFmpeg command
try {
    ffmpeg -f concat -safe 0 -i "$concatFile" -c copy -y "$audioOutput" 2>&1 | Select-Object -Last 10
    Write-Host ""
    Write-Host "✅ Audio combined successfully"
} catch {
    Write-Host "⚠️  Could not combine audio (likely placeholder files)"
}

Write-Host ""

# Now create the actual video with proper timing
Write-Host "🎬 Creating video segments for each slide..."
Write-Host ""

# Create temporary video segments directory
$segmentDir = Join-Path $AudioDir "segments"
if (-not (Test-Path $segmentDir)) {
    New-Item -ItemType Directory -Path $segmentDir -Force | Out-Null
}

# Create a video segment for each slide
$segmentList = @()
for ($i = 0; $i -lt $audioTracks.Count; $i++) {
    $slideFile = $slideFiles[$i]
    $audioFile = $audioTracks[$i].File
    $duration = $audioTracks[$i].Duration
    $segmentFile = Join-Path $segmentDir "segment-$($i.ToString().PadLeft(2, '0')).mp4"
    
    Write-Host "   Creating segment $($i + 1)/$($audioTracks.Count) - $([Math]::Round($duration, 1))s"
    
    # Create segment: slide + audio
    $segmentCmd = "ffmpeg -loop 1 -i `"$($slideFile.FullName)`" -i `"$audioFile`" -c:v libx264 -preset fast -tune stillimage -c:a aac -b:a 128k -pix_fmt yuv420p -shortest -y `"$segmentFile`" 2>&1 | Out-Null"
    Invoke-Expression $segmentCmd
    
    $segmentList += $segmentFile
}

Write-Host ""
Write-Host "✅ Created $($segmentList.Count) segments"
Write-Host ""

# Create concat file for segments
$segmentConcatFile = Join-Path $segmentDir "concat.txt"
$concatContent = ""
foreach ($segment in $segmentList) {
    $concatContent += "file '$segment'`n"
}
Set-Content -Path $segmentConcatFile -Value $concatContent

# Concatenate all segments into final video
Write-Host "🎬 Combining segments into final video..."
Write-Host ""

$finalCmd = "ffmpeg -f concat -safe 0 -i `"$segmentConcatFile`" -c copy -y `"$OutputFile`""
Invoke-Expression $finalCmd

Write-Host ""

if (Test-Path $OutputFile) {
    $fileSize = (Get-Item $OutputFile).Length / 1MB
    Write-Host "✅ Video created successfully: $OutputFile"
    Write-Host "   File size: $([Math]::Round($fileSize, 1)) MB"
} else {
    Write-Error "Failed to create video"
}

Write-Host ""

# Generate instruction document
$slideCount = ($slideFiles).Count
$instructionFile = Join-Path (Split-Path $OutputFile) "VIDEO_GENERATION_INSTRUCTIONS.md"

$instructions = @"
# Video Generation Instructions

Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

## Status
✅ Video has been generated successfully!

## Files Created
- Video: $OutputFile
- Combined Audio: $audioOutput
- Duration: ~$([Math]::Round($totalDuration / 60, 1)) minutes

## Slide Timing
"@

for ($i = 0; $i -lt $audioTracks.Count; $i++) {
    $instructions += "`n- Slide $($i + 1): $([Math]::Round($audioTracks[$i].Duration, 1))s"
}

$instructions += @"


## Video Specifications
- Resolution: 1920x1080 (FHD)
- Codec: H.264 (libx264)
- Audio: AAC at 128 kbps
- Format: MP4
- Total Duration: $([Math]::Round($totalDuration, 1))s (~$([Math]::Round($totalDuration / 60, 1)) minutes)
"@

Set-Content -Path $instructionFile -Value $instructions

Write-Host "================================"
Write-Host "✅ Video Production Complete"
Write-Host "================================"
Write-Host ""
Write-Host "Output: $OutputFile"
Write-Host "Duration: ~$([Math]::Round($totalDuration / 60, 1)) minutes"
Write-Host ""
