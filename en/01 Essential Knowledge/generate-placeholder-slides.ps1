$ErrorActionPreference = 'Stop'

$base = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent -Path $MyInvocation.MyCommandPath }
$slidesDir = Join-Path $base 'slides'
if (-not (Test-Path $slidesDir)) { New-Item -ItemType Directory -Path $slidesDir | Out-Null }

Add-Type -AssemblyName System.Drawing

$slides = @(
    @{ Num = 1; Title = "ARROYO® 1K"; Subtitle = "Waterborne White Topcoat Training"; Points = @(
        "Professional-grade waterborne finishing",
        "Single-component, ready-to-use formula",
        "Industry-leading clarity and durability"
    ) },
    @{ Num = 2; Title = "What is ARROYO® 1K?"; Subtitle = "The Fundamentals"; Points = @(
        "Single-component (ready-to-use)",
        "Waterborne technology",
        "Water-based carrier (eco-friendly)",
        "Fast-drying professional topcoat"
    ) },
    @{ Num = 3; Title = "Key Features"; Subtitle = "What Sets ARROYO® 1K Apart"; Points = @(
        "Crystal Clear Clarity",
        "Low VOC Compliance",
        "Superior Hardness",
        "Quick Recoat Times",
        "Excellent Flow & Leveling"
    ) },
    @{ Num = 4; Title = "Technical Specifications"; Subtitle = "The Numbers"; Points = @(
        "35% Solids Content",
        "<100 g/L VOC",
        "Tack-free: 2-4 hours",
        "Recoat ready: 4-6 hours",
        "Full cure: 24-48 hours"
    ) },
    @{ Num = 5; Title = "Primary Applications"; Subtitle = "Where ARROYO® 1K Excels"; Points = @(
        "Furniture Finishing",
        "Cabinetry",
        "Doors & Trim",
        "Specialty Projects"
    ) },
    @{ Num = 6; Title = "Benefits vs. Traditional"; Subtitle = "Why Professionals Choose ARROYO® 1K"; Points = @(
        "Lower environmental impact",
        "Safer for workers",
        "Easier cleanup",
        "Regulatory compliance",
        "Superior hardness (water-based)"
    ) },
    @{ Num = 7; Title = "Environmental Responsibility"; Subtitle = "Sustainable Finishing"; Points = @(
        "Low VOC emissions",
        "Reduced air pollution",
        "Easier disposal methods",
        "Eco-friendly water carrier",
        "Professional-grade performance"
    ) },
    @{ Num = 8; Title = "Summary"; Subtitle = "ARROYO® 1K: The Professional Choice"; Points = @(
        "Single-component waterborne topcoat",
        "Professional hardness & clarity",
        "Fast drying & easy application",
        "Environmentally responsible",
        "Next: Application Techniques"
    ) }
)

foreach ($s in $slides) {
    $bmp = New-Object Drawing.Bitmap 1920, 1080
    $g = [Drawing.Graphics]::FromImage($bmp)

    $bg = [Drawing.SolidBrush]::new([Drawing.Color]::FromArgb(255, 245, 245, 245))
    $fg = [Drawing.SolidBrush]::new([Drawing.Color]::FromArgb(255, 26, 26, 26))
    $g.FillRectangle($bg, 0, 0, 1920, 1080)

    $titleFont = New-Object Drawing.Font('Segoe UI', 48, [Drawing.FontStyle]::Bold)
    $subFont = New-Object Drawing.Font('Segoe UI', 28, [Drawing.FontStyle]::Regular)
    $pointFont = New-Object Drawing.Font('Segoe UI', 26, [Drawing.FontStyle]::Regular)
    $g.TextRenderingHint = 'AntiAlias'

    $g.DrawString($s.Title, $titleFont, $fg, 80, 80)
    $g.DrawString($s.Subtitle, $subFont, $fg, 80, 160)
    $y = 260
    foreach ($p in $s.Points) {
        $g.DrawString("• $p", $pointFont, $fg, 100, $y)
        $y += 60
    }

    $out = Join-Path $slidesDir ("slide-" + $s.Num.ToString('00') + ".png")
    $bmp.Save($out, [Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose()
    Write-Host "Created $out"
}

Write-Host "Done creating placeholder slides."
