# Essential Knowledge - Video Production Guide

**Module:** 01 Essential Knowledge  
**Product:** ARROYO® 1K Waterborne White Topcoat (W14095)  
**Status:** Ready for Production  
**Estimated Duration:** 8-10 minutes

---

## Quick Start

### Build Complete Video
```powershell
cd "C:\Users\Owner\Local Sites\mlcampbell\projects\product-videos\W14095\en\01 Essential Knowledge"

# Run complete production pipeline
.\build-video.ps1

# Or step-by-step
.\build-video.ps1 -Step audio      # Generate audio only
.\build-video.ps1 -Step slides     # Generate slides only
.\build-video.ps1 -Step video      # Generate video only
.\build-video.ps1 -Step validate   # Check output
```

### With ElevenLabs API
```powershell
$env:ELEVENLABS_API_KEY = "your-api-key"
.\build-video.ps1
```

---

## Directory Structure

```
01 Essential Knowledge/
├── script/                          # Training script source files
│   └── script.md                    # ✏️ EDIT THIS - Training narration
├── video/                           # Generated content
│   ├── audio/                       # Generated audio files
│   │   ├── slide-01.mp3
│   │   ├── slide-02.mp3
│   │   ├── ...
│   │   └── combined.mp3            # All audio merged
│   ├── slides/                      # Generated slide images
│   │   ├── slide-01.png
│   │   ├── slide-02.png
│   │   └── ...
│   └── W14095-01-essential-knowledge.mp4  # 🎬 Final video output
├── build-video.ps1                  # Video production script
└── README.md                        # This file
```

**Note:** Production tools (audio-generator, slide-generator, etc.) are centralized in:
```
C:\Users\Owner\Local Sites\mlcampbell\projects\video-tools\
```

---

## 📊 Content Breakdown

| # | Slide Title | Key Content | Duration |
|---|---|---|---|
| 1 | Product Introduction | Welcome, training overview | ~1 min |
| 2 | What is ARROYO® 1K? | Single-component, waterborne, ready-to-use | ~1 min |
| 3 | Key Features | Clarity, hardness, low VOC, fast recoat, flow | ~1.5 min |
| 4 | Technical Specifications | 35% solids, <100 g/L VOC, drying times | ~1 min |
| 5 | Primary Applications | Furniture, cabinetry, doors, specialty projects | ~1 min |
| 6 | Benefits vs. Traditional | Environmental, health, performance advantages | ~1.5 min |
| 7 | Environmental Responsibility | VOC reduction, easier disposal, stewardship | ~1 min |
| 8 | Summary | Recap and next module preview | ~1 min |
| | **TOTAL** | | **~9 minutes** |

---

## Production Tools

All reusable production scripts are centralized at:
```
C:\Users\Owner\Local Sites\mlcampbell\projects\video-tools\
```

### Available Tools
- **audio-generator-v2.ps1** - Convert script to speech (ElevenLabs TTS)
- **slide-generator.ps1** - Generate slide images from script
- **video-generator.ps1** - Assemble audio + slides into video
- **VIDEO_GENERATION_INSTRUCTIONS.md** - Technical documentation

These tools can be used across all product training videos.

---

## Editing the Script

The training script is stored in `script/script.md` and contains:
- Slide titles and narration
- Inline editing guidance
- Duration estimates
- Best practice notes

**To edit:**
1. Open `script/script.md` in your editor
2. Make changes to the Narrative sections
3. Follow the inline guidance comments
4. Rebuild video with `.\build-video.ps1`

**Or edit on GitHub:**
- https://github.com/thisismyurl/mlcampbell-w14095-training

---

## Output Files

### Final Video
- **Location:** `video/W14095-01-essential-knowledge.mp4`
- **Naming:** `{ProductCode}-{ModuleNumber}-{module-name}.mp4`
- **Duration:** ~9 minutes
- **Resolution:** 1920x1080 (1080p)

### Generated Assets
- **Audio:** `video/audio/slide-*.mp3` (individual) + `combined.mp3` (merged)
- **Slides:** `video/slides/slide-*.png` + metadata files
- **Segments:** `video/audio/segments/segment-*.mp4` (temporary)

---

## Requirements

### Software
- PowerShell 5.0+
- FFmpeg (for video assembly)
- ImageMagick (for slide generation)

### API Keys (Optional)
- ElevenLabs API key for TTS (placeholders generated if not provided)

### Environment Variables
```powershell
$env:ELEVENLABS_API_KEY = "your-key-here"
```

---

## Troubleshooting

### Build fails with "tools not found"
Ensure video-tools directory exists:
```powershell
Test-Path "C:\Users\Owner\Local Sites\mlcampbell\projects\video-tools"
```

### Audio generation creates placeholders
Set ElevenLabs API key or audio-config.json must be configured.

### Video quality issues
Check FFmpeg output logs in the video directory.

---

## Next Steps

After generating this module:
1. Review video output for quality
2. Update script based on feedback
3. Rebuild with `.\build-video.ps1 -Force`
4. Move to next module (02 Application, etc.)

---

**Last Updated:** January 14, 2026
