#Requires -Version 5.0
<#
.SYNOPSIS
    Build training video for W14095 - Essential Knowledge module

.DESCRIPTION
    Orchestrates the complete video production pipeline:
    1. Generates audio from script using ElevenLabs TTS
    2. Generates slides from script content
    3. Assembles final video from audio and slides
    
    Uses centralized tools from video-tools directory.

.PARAMETER Step
    Run specific step only: audio, slides, video, or validate

.PARAMETER Force
    Regenerate even if output files exist

.EXAMPLE
    .\build-video.ps1
    Run complete production pipeline

.EXAMPLE
    .\build-video.ps1 -Step audio
    Generate audio only

.EXAMPLE
    .\build-video.ps1 -Force
    Regenerate all content even if exists
#>

param(
    [ValidateSet("audio", "slides", "video", "validate", "all")]
    [string]$Step = "all",
    
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# Configuration
$productCode = "W14095"
$moduleName = "01 Essential Knowledge"
$videoTitle = "$productCode - Essential Knowledge"

$scriptDir = $PSScriptRoot
$scriptFile = Join-Path $scriptDir "script\script.md"
$videoDir = Join-Path $scriptDir "video"
$audioDir = Join-Path $videoDir "audio"
$slidesDir = Join-Path $videoDir "slides"
$outputVideo = Join-Path $videoDir "$productCode-01-essential-knowledge.mp4"

# Paths to centralized tools
$toolsDir = "C:\Users\Owner\Local Sites\mlcampbell\projects\video-tools"
$audioGenerator = Join-Path $toolsDir "audio-generator-v2.ps1"
$slideGenerator = Join-Path $toolsDir "slide-generator.ps1"
$videoGenerator = Join-Path $toolsDir "video-generator.ps1"

# Ensure directories exist
New-Item -ItemType Directory -Force -Path $videoDir, $audioDir, $slidesDir | Out-Null

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Building Video: $videoTitle" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Validate prerequisites
if (-not (Test-Path $scriptFile)) {
    Write-Error "Script file not found: $scriptFile"
}

if (-not (Test-Path $toolsDir)) {
    Write-Error "Video tools directory not found: $toolsDir"
}

# Function to run a step
function Invoke-Step {
    param($Name, $ScriptPath, $Arguments)
    
    Write-Host "► Step: $Name" -ForegroundColor Yellow
    Write-Host ""
    
    try {
        & $ScriptPath @Arguments
        Write-Host ""
        Write-Host "✅ $Name completed successfully" -ForegroundColor Green
        Write-Host ""
        return $true
    }
    catch {
        Write-Host ""
        Write-Host "❌ $Name failed: $_" -ForegroundColor Red
        Write-Host ""
        return $false
    }
}

# Run requested steps
$success = $true

if ($Step -eq "all" -or $Step -eq "audio") {
    $audioArgs = @{
        ScriptPath = $scriptFile
        OutputDir = $audioDir
    }
    if ($Force) { $audioArgs.Force = $true }
    
    $success = $success -and (Invoke-Step "Audio Generation" $audioGenerator $audioArgs)
}

if ($Step -eq "all" -or $Step -eq "slides") {
    $slideArgs = @{
        ScriptPath = $scriptFile
        OutputDir = $slidesDir
        ProductCode = $productCode
    }
    if ($Force) { $slideArgs.Force = $true }
    
    $success = $success -and (Invoke-Step "Slide Generation" $slideGenerator $slideArgs)
}

if ($Step -eq "all" -or $Step -eq "video") {
    $videoArgs = @{
        AudioDir = $audioDir
        SlideDir = $slidesDir
        OutputPath = $outputVideo
        Title = $videoTitle
    }
    if ($Force) { $videoArgs.Force = $true }
    
    $success = $success -and (Invoke-Step "Video Assembly" $videoGenerator $videoArgs)
}

if ($Step -eq "validate") {
    Write-Host "► Validation" -ForegroundColor Yellow
    Write-Host ""
    
    $audioFiles = Get-ChildItem -Path $audioDir -Filter "slide-*.mp3" -ErrorAction SilentlyContinue
    $slideFiles = Get-ChildItem -Path $slidesDir -Filter "slide-*.png" -ErrorAction SilentlyContinue
    
    Write-Host "Script file:   $(if (Test-Path $scriptFile) { '✅' } else { '❌' })" -ForegroundColor $(if (Test-Path $scriptFile) { 'Green' } else { 'Red' })
    Write-Host "Audio files:   $($audioFiles.Count) found" -ForegroundColor $(if ($audioFiles.Count -gt 0) { 'Green' } else { 'Yellow' })
    Write-Host "Slide files:   $($slideFiles.Count) found" -ForegroundColor $(if ($slideFiles.Count -gt 0) { 'Green' } else { 'Yellow' })
    Write-Host "Output video:  $(if (Test-Path $outputVideo) { '✅ ' + (Get-Item $outputVideo).Length / 1MB -as [int]) + ' MB' } else { '❌ Not found' })" -ForegroundColor $(if (Test-Path $outputVideo) { 'Green' } else { 'Red' })
    Write-Host ""
}

# Summary
Write-Host "========================================" -ForegroundColor Cyan
if ($success) {
    Write-Host "✅ Production Complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Output: $outputVideo" -ForegroundColor Cyan
    
    if (Test-Path $outputVideo) {
        $videoFile = Get-Item $outputVideo
        Write-Host "Size: $([Math]::Round($videoFile.Length / 1MB, 2)) MB" -ForegroundColor Gray
        Write-Host "Modified: $($videoFile.LastWriteTime)" -ForegroundColor Gray
    }
} else {
    Write-Host "❌ Production failed - check errors above" -ForegroundColor Red
    exit 1
}
Write-Host "========================================" -ForegroundColor Cyan
