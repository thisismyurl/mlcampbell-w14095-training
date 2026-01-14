#Requires -Version 5.0
<#
.SYNOPSIS
    Enhanced audio generator with configurable character filtering and pronunciation overrides.

.DESCRIPTION
    Converts narrative content from script.md into MP3 audio files using ElevenLabs API.
    Supports configuration-driven character filtering and pronunciation overrides via audio-config.json.

.PARAMETER ScriptPath
    Path to the script.md file

.PARAMETER OutputDir
    Output directory for audio files

.PARAMETER Voice
    ElevenLabs voice ID to use

.PARAMETER ApiKey
    ElevenLabs API key (or reads from env var ELEVENLABS_API_KEY)

.PARAMETER ConfigPath
    Path to audio-config.json (defaults to ../audio-config.json)

.PARAMETER Force
    Regenerate audio even if files already exist

.EXAMPLE
    .\audio-generator-v2.ps1
    
.EXAMPLE
    .\audio-generator-v2.ps1 -Force -ConfigPath ".\my-config.json"
#>

param(
    [string]$ScriptPath = ".\script.md",
    [string]$OutputDir = ".\audio",
    [string]$Voice = "EXAVITQu4emMWXw3c5H5",  # Professional male voice
    [string]$ApiKey = $env:ELEVENLABS_API_KEY,
    [string]$Model = "eleven_multilingual_v2",
    [string]$ConfigPath = "..\audio-config.json",
    [switch]$Force,
    [switch]$ShowCleaning  # Show before/after text cleaning
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

# Load audio configuration
$config = $null
if (Test-Path $ConfigPath) {
    Write-Host "📋 Loading audio config: $ConfigPath"
    $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
} else {
    Write-Warning "Config file not found: $ConfigPath - using default cleaning only"
}

# Create output directory
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

<#
.SYNOPSIS
    Cleans text for audio generation using config-driven rules
#>
function Clean-TextForAudio {
    param(
        [string]$Text,
        [object]$Config
    )
    
    $cleanedText = $Text
    
    # Apply character filters
    if ($Config -and $Config.characterFilters -and $Config.characterFilters.filters) {
        foreach ($filter in $Config.characterFilters.filters) {
            $cleanedText = $cleanedText -replace [regex]::Escape($filter.character), $filter.replacement
        }
    }
    
    # Apply pronunciation overrides (only enabled ones)
    if ($Config -and $Config.pronunciationOverrides -and $Config.pronunciationOverrides.overrides) {
        foreach ($override in $Config.pronunciationOverrides.overrides | Where-Object { $_.enabled }) {
            # Use word boundary matching for whole words to avoid partial replacements
            $pattern = "\b$([regex]::Escape($override.original))\b"
            $cleanedText = $cleanedText -replace $pattern, $override.replacement
        }
    }
    
    # Apply custom pronunciations (only enabled ones)
    if ($Config -and $Config.customPronunciations -and $Config.customPronunciations.examples) {
        foreach ($custom in $Config.customPronunciations.examples | Where-Object { $_.enabled }) {
            $pattern = "\b$([regex]::Escape($custom.original))\b"
            $cleanedText = $cleanedText -replace $pattern, $custom.replacement
        }
    }
    
    # Apply text cleaning rules (markdown, formatting, etc.)
    if ($Config -and $Config.textCleaning -and $Config.textCleaning.rules) {
        foreach ($rule in $Config.textCleaning.rules) {
            $cleanedText = $cleanedText -replace $rule.pattern, $rule.replacement
        }
    }
    
    # Default cleaning for markdown and special characters (fallback if no config)
    $cleanedText = $cleanedText `
        -replace '\*\*', '' `
        -replace '`', '' `
        -replace '\[', '' `
        -replace '\]', '' `
        -replace '[\u{1F300}-\u{1F9FF}]', '' `
        -replace '[\u{2600}-\u{26FF}]', '' `
        -replace '[\u{2700}-\u{27BF}]', '' `
        -replace '[🎨🎬🎙️📝📊✅⚠️❌🔍🎵]', ''
    
    # Clean up extra whitespace
    $cleanedText = $cleanedText -replace '\s+', ' '
    $cleanedText = $cleanedText.Trim()
    
    return $cleanedText
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

# Display loaded configuration
if ($config) {
    $enabledOverrides = ($config.pronunciationOverrides.overrides | Where-Object { $_.enabled }).Count
    Write-Host "🎯 Pronunciation overrides loaded: $enabledOverrides enabled"
    
    if ($config.pronunciationOverrides.overrides | Where-Object { $_.enabled }) {
        Write-Host "   Active overrides:"
        foreach ($override in ($config.pronunciationOverrides.overrides | Where-Object { $_.enabled })) {
            Write-Host "   • '$($override.original)' → '$($override.replacement)'"
        }
    }
}

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
        $successCount++
        continue
    }
    
    # Clean narrative for audio using configuration
    $audioText = Clean-TextForAudio -Text $narrative -Config $config
    
    if ($ShowCleaning) {
        Write-Host ""
        Write-Host "📝 Original text:" -ForegroundColor Cyan
        Write-Host "   $($narrative.Substring(0, [Math]::Min(150, $narrative.Length)))..."
        Write-Host "🧹 Cleaned text:" -ForegroundColor Green
        Write-Host "   $($audioText.Substring(0, [Math]::Min(150, $audioText.Length)))..."
        Write-Host ""
    }
    
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
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "   Response: $responseBody" -ForegroundColor Red
        }
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
Write-Host "💡 Tips:"
Write-Host "   • Edit ..\audio-config.json to add pronunciation overrides"
Write-Host "   • Use -ShowCleaning to see before/after text processing"
Write-Host "   • Use -Force to regenerate existing audio files"
Write-Host ""
Write-Host "Next step: Generate slides to match this audio"
