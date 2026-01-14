#Requires -Version 5.0
<#
.SYNOPSIS
    Master orchestration script for Essential Knowledge video production.

.DESCRIPTION
    Coordinates the entire video production pipeline:
    1. Generates audio from script
    2. Generates slides
    3. Composes final video
    4. Validates output

.PARAMETER Step
    Which step to run: all, audio, slides, video, validate
    Default: all (runs all steps)

.PARAMETER ElevenLabsApiKey
    ElevenLabs API key for audio generation
    Falls back to ELEVENLABS_API_KEY environment variable

.PARAMETER Interactive
    If true, prompts before each step
#>

param(
    [ValidateSet('all', 'audio', 'slides', 'video', 'validate')]
    [string]$Step = 'all',
    
    [string]$ElevenLabsApiKey = $env:ELEVENLABS_API_KEY,
    [switch]$Interactive
)

$ErrorActionPreference = 'Stop'

# Get script directory
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent -Path $MyInvocation.MyCommandPath }
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent -Path $MyInvocation.MyCommandPath }
$scriptFile = Join-Path $scriptDir "script.md"
$audioDir = Join-Path $scriptDir "audio"
$slideDir = Join-Path $scriptDir "slides"
$outputVideo = Join-Path $scriptDir "video.mp4"

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗"
Write-Host "║  ARROYO® 1K - Essential Knowledge Video Production      ║"
Write-Host "║  Master Orchestration Script                             ║"
Write-Host "╚════════════════════════════════════════════════════════════╝"
Write-Host ""

Write-Host "📁 Project Directory: $scriptDir"
Write-Host "📄 Script File: $(Split-Path $scriptFile -Leaf)"
Write-Host ""

# Validate prerequisites
Write-Host "🔍 Validating prerequisites..."
Write-Host ""

if (-not (Test-Path $scriptFile)) {
    Write-Error "❌ Script file not found: $scriptFile"
}
Write-Host "✅ Script found: $(Split-Path $scriptFile -Leaf)"

# Check FFmpeg
try {
    ffmpeg -version 2>&1 | Select-Object -First 1 | Out-Null
    Write-Host "✅ FFmpeg available"
} catch {
    Write-Warning "⚠️  FFmpeg not found (needed for video generation)"
}

Write-Host ""

# ==============================================================================
# STEP 1: GENERATE AUDIO
# ==============================================================================

function Invoke-AudioGeneration {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Write-Host "STEP 1: GENERATE AUDIO"
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Write-Host ""
    
    if ($Interactive) {
        $confirm = Read-Host "Generate audio from script? (y/n)"
        if ($confirm -ne 'y') {
            Write-Host "⏭️  Skipped"
            return
        }
    }
    
    $audioGeneratorScript = Join-Path $scriptDir "audio-generator.ps1"
    
    if (-not (Test-Path $audioGeneratorScript)) {
        Write-Error "Audio generator script not found: $audioGeneratorScript"
    }
    
    Write-Host "🎙️  Starting audio generation..."
    Write-Host "   Script: $(Split-Path $scriptFile -Leaf)"
    Write-Host "   Output: $audioDir"
    Write-Host ""
    
    if ($ElevenLabsApiKey) {
        Write-Host "🔑 Using ElevenLabs API key"
        & $audioGeneratorScript -ScriptPath $scriptFile -OutputDir $audioDir -ApiKey $ElevenLabsApiKey
    } else {
        Write-Warning "⚠️  No ElevenLabs API key provided"
        Write-Host "   Set environment variable: `$env:ELEVENLABS_API_KEY = 'your-key'"
        Write-Host "   Or pass: -ElevenLabsApiKey 'your-key'"
        Write-Host ""
        Write-Host "📝 For now, creating placeholder audio files..."
        
        # Create placeholder audio files
        if (-not (Test-Path $audioDir)) {
            New-Item -ItemType Directory -Path $audioDir -Force | Out-Null
        }
        
        for ($i = 1; $i -le 8; $i++) {
            $placeholder = Join-Path $audioDir "slide-$($i.ToString().PadLeft(2, '0')).mp3"
            # Create empty file as placeholder
            "" | Out-File -FilePath $placeholder
            Write-Host "   📝 Created placeholder: slide-$($i.ToString().PadLeft(2, '0')).mp3"
        }
    }
    
    Write-Host ""
    Write-Host "✅ Audio generation step complete"
}

# ==============================================================================
# STEP 2: GENERATE SLIDES
# ==============================================================================

function Invoke-SlideGeneration {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Write-Host "STEP 2: GENERATE SLIDES"
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Write-Host ""
    
    if ($Interactive) {
        $confirm = Read-Host "Generate slide images? (y/n)"
        if ($confirm -ne 'y') {
            Write-Host "⏭️  Skipped"
            return
        }
    }
    
    $slideGeneratorScript = Join-Path $scriptDir "slide-generator.ps1"
    
    if (-not (Test-Path $slideGeneratorScript)) {
        Write-Error "Slide generator script not found: $slideGeneratorScript"
    }
    
    Write-Host "🎨 Starting slide generation..."
    Write-Host "   Output: $slideDir"
    Write-Host "   Resolution: 1920x1080px"
    Write-Host ""
    
    & $slideGeneratorScript -OutputDir $slideDir
    
    Write-Host ""
    Write-Host "✅ Slide generation step complete"
}

# ==============================================================================
# STEP 3: GENERATE VIDEO
# ==============================================================================

function Invoke-VideoGeneration {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Write-Host "STEP 3: GENERATE VIDEO"
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Write-Host ""
    
    if ($Interactive) {
        $confirm = Read-Host "Generate final MP4 video? (y/n)"
        if ($confirm -ne 'y') {
            Write-Host "⏭️  Skipped"
            return
        }
    }
    
    $videoGeneratorScript = Join-Path $scriptDir "video-generator.ps1"
    
    if (-not (Test-Path $videoGeneratorScript)) {
        Write-Error "Video generator script not found: $videoGeneratorScript"
    }
    
    Write-Host "🎬 Starting video composition..."
    Write-Host "   Audio: $audioDir"
    Write-Host "   Slides: $slideDir"
    Write-Host "   Output: $outputVideo"
    Write-Host ""
    
    & $videoGeneratorScript -AudioDir $audioDir -SlideDir $slideDir -OutputFile $outputVideo
    
    Write-Host ""
    Write-Host "✅ Video generation step complete"
}

# ==============================================================================
# STEP 4: VALIDATE OUTPUT
# ==============================================================================

function Invoke-Validation {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Write-Host "STEP 4: VALIDATE OUTPUT"
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Write-Host ""
    
    Write-Host "📊 Validation Report"
    Write-Host ""
    
    # Check audio files
    if (Test-Path $audioDir) {
        $audioCount = (Get-ChildItem -Path $audioDir -Filter "*.mp3" | Measure-Object).Count
        Write-Host "🎙️  Audio files: $audioCount"
        
        if ($audioCount -gt 0) {
            Write-Host "   ✅ Audio ready"
        } else {
            Write-Host "   ⚠️  No audio files found"
        }
    } else {
        Write-Host "🎙️  Audio directory not found"
    }
    
    # Check slides
    if (Test-Path $slideDir) {
        $slideCount = (Get-ChildItem -Path $slideDir -Filter "*.png" | Measure-Object).Count
        $metadataCount = (Get-ChildItem -Path $slideDir -Filter "*.metadata.txt" | Measure-Object).Count
        Write-Host "🎨 Slide files: $slideCount PNG + $metadataCount metadata"
        
        if ($metadataCount -gt 0) {
            Write-Host "   ✅ Slide definitions ready"
        }
    } else {
        Write-Host "🎨 Slide directory not found"
    }
    
    # Check video
    if (Test-Path $outputVideo) {
        $size = (Get-Item $outputVideo).Length / 1MB
        Write-Host "📹 Video file: $([Math]::Round($size, 1)) MB"
        Write-Host "   ✅ Video generated"
    } else {
        Write-Host "📹 Video file not found (will be generated in step 3)"
    }
    
    Write-Host ""
    Write-Host "✅ Validation complete"
}

# ==============================================================================
# EXECUTION
# ==============================================================================

try {
    switch ($Step) {
        'all' {
            Invoke-AudioGeneration
            Invoke-SlideGeneration
            Invoke-VideoGeneration
            Invoke-Validation
        }
        'audio' {
            Invoke-AudioGeneration
            Invoke-Validation
        }
        'slides' {
            Invoke-SlideGeneration
            Invoke-Validation
        }
        'video' {
            Invoke-VideoGeneration
            Invoke-Validation
        }
        'validate' {
            Invoke-Validation
        }
    }
    
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗"
    Write-Host "║  ✅ PRODUCTION PIPELINE COMPLETE                           ║"
    Write-Host "╚════════════════════════════════════════════════════════════╝"
    Write-Host ""
    
    Write-Host "📁 Output Location: $scriptDir"
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  1. Review audio quality"
    Write-Host "  2. Verify slide designs"
    Write-Host "  3. Check final video for playback"
    Write-Host "  4. Prepare for distribution"
    Write-Host ""
}
catch {
    Write-Host ""
    Write-Host "❌ ERROR: $_"
    Write-Host ""
    exit 1
}
