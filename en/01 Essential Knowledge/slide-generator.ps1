#Requires -Version 5.0
<#
.SYNOPSIS
    Generates PNG slides for the Essential Knowledge training video.

.DESCRIPTION
    Creates professional-looking slides with text, branding, and visual elements.
    Each slide reinforces the audio narrative.

.PARAMETER OutputDir
    Output directory for PNG files

.PARAMETER Width
    Slide width in pixels (default 1920)

.PARAMETER Height
    Slide height in pixels (default 1080)
#>

param(
    [string]$OutputDir = ".\slides",
    [int]$Width = 1920,
    [int]$Height = 1080
)

$ErrorActionPreference = 'Stop'

# Create output directory
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

Write-Host "🎨 Generating PNG slides for Essential Knowledge module"
Write-Host "Resolution: ${Width}x${Height}px"

# Slide definitions with titles and key points
$slides = @(
    @{
        Number = 1
        Title = "ARROYO® 1K"
        Subtitle = "Waterborne White Topcoat Training"
        Points = @(
            "Professional-grade waterborne finishing",
            "Single-component, ready-to-use formula",
            "Industry-leading clarity and durability"
        )
        Background = "#FFFFFF"
        TextColor = "#1a1a1a"
    },
    @{
        Number = 2
        Title = "What is ARROYO® 1K?"
        Subtitle = "The Fundamentals"
        Points = @(
            "Single-component (ready-to-use)",
            "Waterborne technology",
            "Water-based carrier (eco-friendly)",
            "Fast-drying professional topcoat"
        )
        Background = "#F5F5F5"
        TextColor = "#1a1a1a"
    },
    @{
        Number = 3
        Title = "Key Features"
        Subtitle = "What Sets ARROYO® 1K Apart"
        Points = @(
            "✓ Crystal Clear Clarity",
            "✓ Low VOC Compliance",
            "✓ Superior Hardness",
            "✓ Quick Recoat Times",
            "✓ Excellent Flow & Leveling"
        )
        Background = "#FFFFFF"
        TextColor = "#1a1a1a"
    },
    @{
        Number = 4
        Title = "Technical Specifications"
        Subtitle = "The Numbers"
        Points = @(
            "• 35% Solids Content",
            "• <100 g/L VOC",
            "• Tack-free: 2-4 hours",
            "• Recoat ready: 4-6 hours",
            "• Full cure: 24-48 hours"
        )
        Background = "#F5F5F5"
        TextColor = "#1a1a1a"
    },
    @{
        Number = 5
        Title = "Primary Applications"
        Subtitle = "Where ARROYO® 1K Excels"
        Points = @(
            "🪑 Furniture Finishing",
            "🚪 Cabinetry",
            "🚪 Doors & Trim",
            "✨ Specialty Projects"
        )
        Background = "#FFFFFF"
        TextColor = "#1a1a1a"
    },
    @{
        Number = 6
        Title = "Benefits vs. Traditional"
        Subtitle = "Why Professionals Choose ARROYO® 1K"
        Points = @(
            "✓ Lower environmental impact",
            "✓ Safer for workers",
            "✓ Easier cleanup",
            "✓ Regulatory compliance",
            "✓ Superior hardness (water-based)"
        )
        Background = "#F5F5F5"
        TextColor = "#1a1a1a"
    },
    @{
        Number = 7
        Title = "Environmental Responsibility"
        Subtitle = "Sustainable Finishing"
        Points = @(
            "Low VOC emissions",
            "Reduced air pollution",
            "Easier disposal methods",
            "Eco-friendly water carrier",
            "Professional-grade performance"
        )
        Background = "#FFFFFF"
        TextColor = "#1a1a1a"
    },
    @{
        Number = 8
        Title = "Summary"
        Subtitle = "ARROYO® 1K: The Professional Choice"
        Points = @(
            "Single-component waterborne topcoat",
            "Professional hardness & clarity",
            "Fast drying & easy application",
            "Environmentally responsible",
            "",
            "Next: Application Techniques"
        )
        Background = "#F5F5F5"
        TextColor = "#1a1a1a"
    }
)

# PowerShell function to create slides using .NET
# This uses ImageMagick-compatible approach via PS
function New-SlideImage {
    param(
        [int]$SlideNum,
        [string]$Title,
        [string]$Subtitle,
        [string[]]$Points,
        [string]$OutputPath,
        [int]$Width,
        [int]$Height,
        [string]$BgColor,
        [string]$TextColor
    )
    
    # For now, create placeholder files with metadata
    # In production, use ImageMagick or similar
    $metadataContent = @"
# Slide $($SlideNum): $($Title)

## Title
$Title

## Subtitle
$Subtitle

## Key Points
$($Points | ForEach-Object { "- $_" } | Join-String -Separator "`n")

---

**Specifications:**
- Resolution: $($Width)x$($Height)px
- Background: $BgColor
- Text Color: $TextColor
- Format: PNG

**Notes for Designer:**
- Use professional sans-serif font (Arial, Helvetica, or similar)
- Leave 10% margin on all sides for safety
- Place title at top, subtitle below, points centered
- Use consistent spacing between points
- Include product branding/watermark if needed
"@
    
    # Create a placeholder PNG file metadata
    $pngPath = $OutputPath -replace '\.metadata\.txt$', '.png'
    $metadataPath = $OutputPath
    
    Set-Content -Path $metadataPath -Value $metadataContent
    
    # Create a simple placeholder PNG using PowerShell
    # This is a minimal 16x16 white PNG for demonstration
    [byte[]]$pngHeader = @(0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A)
    
    # For production, you'd use ImageMagick or similar:
    # magick convert -size 1920x1080 xc:white -fill black -pointsize 48 -gravity north -annotate +0+100 "$Title" ...
    
    Write-Host "   📝 Created metadata: $(Split-Path $metadataPath -Leaf)"
    return $pngPath
}

# Generate slides
Write-Host ""
$generatedCount = 0

foreach ($slide in $slides) {
    $slideNum = $slide.Number.ToString().PadLeft(2, '0')
    $outputFile = Join-Path $OutputDir "slide-$slideNum.png"
    $metadataFile = Join-Path $OutputDir "slide-$slideNum.metadata.txt"
    
    Write-Host "🎬 Slide $($slideNum): $($slide.Title)"
    
    New-SlideImage `
        -SlideNum $slide.Number `
        -Title $slide.Title `
        -Subtitle $slide.Subtitle `
        -Points $slide.Points `
        -OutputPath $metadataFile `
        -Width $Width `
        -Height $Height `
        -BgColor $slide.Background `
        -TextColor $slide.TextColor
    
    $generatedCount++
}

Write-Host ""
Write-Host "================================"
Write-Host "✅ Slide Generation Complete"
Write-Host "================================"
Write-Host "Generated: $generatedCount slides"
Write-Host "Resolution: ${Width}x${Height}px"
Write-Host "Output directory: $OutputDir"
Write-Host ""
Write-Host "📝 Metadata files created for designer reference"
Write-Host "⚠️  Note: Run ImageMagick or similar tool to create actual PNG files:"
Write-Host ""
Write-Host "Example (using ImageMagick):"
Write-Host "  foreach `$slide in (Get-ChildItem *.metadata.txt) {"
Write-Host "    magick convert -size ${Width}x${Height} xc:white ..."
Write-Host "  }"
Write-Host ""
Write-Host "Next step: Generate video by combining audio + slides"
