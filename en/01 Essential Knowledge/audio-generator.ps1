#Requires -Version 5.0
<#
.SYNOPSIS
    Generates audio from the Essential Knowledge script using text-to-speech.

.DESCRIPTION
    Converts narrative content from script.md into MP3 audio files using ElevenLabs API.
    Creates individual audio files for each slide.

.PARAMETER ScriptPath
    Path to the script.md file

.PARAMETER OutputDir
    Output directory for audio files

.PARAMETER Voice
    ElevenLabs voice ID to use

.PARAMETER ApiKey
    ElevenLabs API key (or reads from env var ELEVENLABS_API_KEY)
#>

param(
    [string]$ScriptPath = ".\script.md",
    [string]$OutputDir = ".\audio",
    [string]$Voice = "EXAVITQu4emMWXw3c5H5",  # Professional male voice (override with ELEVENLABS_VOICE_ID_EN)
    [string]$ApiKey = $env:ELEVENLABS_API_KEY,
    [string]$Model = "eleven_multilingual_v2",     # Updated default to supported model
    [switch]$Force                                  # Regenerate even if file exists
)

$ErrorActionPreference = 'Stop'

# Prefer environment voice when caller did not pass -Voice
if (-not $PSBoundParameters.ContainsKey('Voice') -and $env:ELEVENLABS_VOICE_ID_EN) {
    $Voice = $env:ELEVENLABS_VOICE_ID_EN
    Write-Host "🔊 Using ELEVENLABS_VOICE_ID_EN for voice selection"
}

# Verify inputs
if (-not (Test-Path $ScriptPath)) {
    Write-Error "Script file not found: $ScriptPath"
}

if (-not $ApiKey) {
    Write-Error "ElevenLabs API key not provided. Set ELEVENLABS_API_KEY environment variable."
}

# Create output directory
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

Write-Host "📝 Reading script: $ScriptPath"
$scriptContent = Get-Content $ScriptPath -Raw

# Extract slides with narratives
$slides = @()
$currentSlide = $null
$currentNarrative = $null

foreach ($line in $scriptContent -split "`n") {
    if ($line -match "^## Slide (\d+):") {
        if ($currentSlide) {
            $slides += @{
                Number = $currentSlide
                Narrative = $currentNarrative -replace '### Narrative\s+', '' | 
                           ForEach-Object { $_.Trim() } |
                           Where-Object { $_ -and $_ -notmatch '^###' }
            }
        }
        $currentSlide = [int]$matches[1]
        $currentNarrative = ""
    }
    elseif ($currentSlide -and -not ($line -match "^## Slide")) {
        $currentNarrative += "$line`n"
    }
}

# Add last slide
if ($currentSlide) {
    $slides += @{
        Number = $currentSlide
        Narrative = $currentNarrative -replace '### Narrative\s+', '' | 
                   ForEach-Object { $_.Trim() } |
                   Where-Object { $_ -and $_ -notmatch '^###' -and $_ -notmatch '^---' }
    }
}

Write-Host "✅ Found $($slides.Count) slides"

# Generate audio for each slide
$totalDuration = 0
$successCount = 0

foreach ($slide in $slides) {
    $slideNum = $slide.Number
    $narrative = $slide.Narrative | Where-Object { $_ } | Join-String -Separator " "
    
    if (-not $narrative) {
        Write-Warning "Slide $slideNum has no narrative, skipping..."
        continue
    }
    
    $outputFile = Join-Path $OutputDir "slide-$($slideNum.ToString().PadLeft(2, '0')).mp3"
    
    # Skip if already exists and not forcing regeneration
    if (-not $Force -and (Test-Path $outputFile)) {
        Write-Host "⏭️  Slide $slideNum already exists, skipping (use -Force to regenerate)"
        continue
    }
    
    # Clean narrative for audio - remove markdown, symbols, emojis
    $audioText = $narrative `
        -replace '\*\*', '' `
        -replace '`', '' `
        -replace '\[', '' `
        -replace '\]', '' `
        -replace '®', '' `
        -replace '™', '' `
        -replace '©', '' `
        -replace '[\u{1F300}-\u{1F9FF}]', '' `
        -replace '[\u{2600}-\u{26FF}]', '' `
        -replace '[\u{2700}-\u{27BF}]', '' `
        -replace '[🎨🎬🎙️📝📊✅⚠️❌🔍🎵]', ''
    
    Write-Host "🎙️  Slide $slideNum → Generating audio..."
    Write-Host "   Text: $($audioText.Substring(0, [Math]::Min(80, $audioText.Length)))..."
    
    # Call ElevenLabs API
    $body = @{
        text = $audioText
        model_id = $Model
        voice_settings = @{
            stability = 0.5
            similarity_boost = 0.75
        }
    } | ConvertTo-Json
    
    try {
        $response = Invoke-WebRequest `
            -Uri "https://api.elevenlabs.io/v1/text-to-speech/$Voice" `
            -Method POST `
            -Headers @{
                "xi-api-key" = $ApiKey
                "Content-Type" = "application/json"
            } `
            -Body $body `
            -OutFile $outputFile
        
        $fileSize = (Get-Item $outputFile).Length / 1MB
        $duration = [Math]::Round($audioText.Length / 150 * 60)  # Estimate: ~150 chars per minute
        $totalDuration += $duration
        
        Write-Host "   ✅ Created: $(Split-Path $outputFile -Leaf) ($([Math]::Round($fileSize, 2)) MB)"
        $successCount++
    }
    catch {
        Write-Host "   ❌ Failed: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "================================"
Write-Host "✅ Audio Generation Complete"
Write-Host "================================"
Write-Host "Generated: $successCount audio files"
Write-Host "Total estimated duration: ~$($totalDuration / 60) minutes"
Write-Host "Output directory: $OutputDir"
Write-Host ""
Write-Host "Next step: Generate slides to match this audio"
