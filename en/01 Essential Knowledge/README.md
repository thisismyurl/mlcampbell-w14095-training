# Essential Knowledge - Video Production Guide

**Module:** 01 Essential Knowledge  
**Product:** ARROYO® 1K Waterborne White Topcoat  
**Status:** Ready for Production  
**Estimated Duration:** 8-10 minutes

---

## Quick Start

### Option 1: Full Automated Pipeline (Recommended)
```powershell
cd C:\Users\Owner\Local Sites\mlcampbell\projects\product-videos\W14095\en\01 Essential Knowledge

# Run complete production pipeline
.\run-production.ps1

# Or step-by-step
.\run-production.ps1 -Step audio      # Generate audio only
.\run-production.ps1 -Step slides     # Generate slides only
.\run-production.ps1 -Step video      # Generate video only
.\run-production.ps1 -Step validate   # Check output
```

### Option 2: With ElevenLabs API
```powershell
$env:ELEVENLABS_API_KEY = "your-api-key"
.\run-production.ps1
```

### Option 3: Manual Steps
```powershell
# 1. Generate audio
.\audio-generator.ps1

# 2. Generate slides
.\slide-generator.ps1

# 3. Generate video
.\video-generator.ps1
```

---

## What Gets Created

### 📁 Directory Structure
```
01 Essential Knowledge/
├── script.md                        # Source training script
├── audio/                           # Generated audio files
│   ├── slide-01.mp3
│   ├── slide-02.mp3
│   ├── ...
│   ├── slide-08.mp3
│   └── combined.mp3                # All audio merged
├── slides/                          # Generated slide files
│   ├── slide-01.png
│   ├── slide-02.png
│   ├── ...
│   └── slide-08.png
└── video.mp4                        # Final output video
```

### 📊 Content Breakdown

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

## Scripts Included

### 1. `audio-generator.ps1`
**Purpose:** Convert script text to speech audio files  
**Requirements:** ElevenLabs API key (optional, creates placeholders if not provided)  
**Output:** 8 MP3 files, one per slide

**Usage:**
```powershell
.\audio-generator.ps1 -ScriptPath .\script.md -OutputDir .\audio -ApiKey "your-key"
```

**Features:**
- Parses script.md and extracts narrative text
- Calls ElevenLabs TTS API with professional voice
- Creates individual audio files per slide
- Estimates total video duration

### 2. `slide-generator.ps1`
**Purpose:** Create visual slide definitions and metadata  
**Requirements:** None  
**Output:** 8 PNG images + metadata files

**Usage:**
```powershell
.\slide-generator.ps1 -OutputDir .\slides -Width 1920 -Height 1080
```

**Features:**
- Creates 8 slides with professional design
- Generates 1920x1080 (FHD) images
- Creates metadata files for designers
- Consistent branding and color scheme

**Metadata Includes:**
- Slide title and subtitle
- Key points and bullet content
- Background and text colors
- Design specifications

### 3. `video-generator.ps1`
**Purpose:** Combine audio and slides into final MP4 video  
**Requirements:** FFmpeg installed  
**Output:** Single video.mp4 file

**Usage:**
```powershell
.\video-generator.ps1 -AudioDir .\audio -SlideDir .\slides -OutputFile .\video.mp4
```

**Features:**
- Concatenates multiple audio files
- Times slides to audio duration
- Creates H.264 encoded MP4
- Generates FFmpeg command reference
- Produces video generation instructions

### 4. `run-production.ps1`
**Purpose:** Orchestrate entire production pipeline  
**Requirements:** None (all scripts must be in same directory)  
**Output:** Complete video + all intermediate files

**Usage:**
```powershell
# Full pipeline
.\run-production.ps1

# Specific step
.\run-production.ps1 -Step audio
.\run-production.ps1 -Step slides
.\run-production.ps1 -Step video
.\run-production.ps1 -Step validate

# With API key
.\run-production.ps1 -ElevenLabsApiKey "sk-12345..."

# Interactive mode
.\run-production.ps1 -Interactive
```

**Features:**
- Validates prerequisites (FFmpeg, API key)
- Runs all 4 steps with clear progress indication
- Creates placeholder files if API key not available
- Comprehensive error handling
- Validation report at completion

---

## Dependencies & Setup

### Required Software
- **PowerShell 5.0+** (usually pre-installed on Windows 10+)
- **FFmpeg** (for final video generation)
  - Download: https://ffmpeg.org/download.html
  - Add to PATH: `C:\Program Files\ffmpeg\bin`

### Optional but Recommended
- **ElevenLabs API Key** (for professional audio generation)
  - Sign up: https://elevenlabs.io
  - Create API key: https://elevenlabs.io/account
  - Store in environment variable: `$env:ELEVENLABS_API_KEY = "your-key"`

### Verify Setup
```powershell
# Check PowerShell version
$PSVersionTable.PSVersion

# Check FFmpeg
ffmpeg -version | Select-Object -First 1

# Check ElevenLabs API
if ($env:ELEVENLABS_API_KEY) { "✅ API key set" } else { "⚠️ No API key" }
```

---

## Production Workflow

### Phase 1: Audio Generation (2-5 minutes)
1. Script parser reads narrative text
2. ElevenLabs API converts text to speech
3. Individual audio files created (8 × MP3)
4. Files saved to `audio/` directory
5. Total duration calculated

**Output:** 8 MP3 files (1-2 MB total)

### Phase 2: Slide Generation (1 minute)
1. Slide definitions created
2. Metadata generated for each slide
3. Professional design specifications set
4. PNG files created (1920×1080 each)
5. Color scheme and branding applied

**Output:** 8 PNG files + 8 metadata files

### Phase 3: Video Composition (5-10 minutes)
1. Audio files concatenated
2. Slides timed to audio duration
3. FFmpeg creates MP4 video
4. H.264 encoding applied
5. Final file written to disk

**Output:** Single MP4 file (50-200 MB depending on bitrate)

### Phase 4: Validation (1 minute)
1. File counts verified
2. File sizes checked
3. Directory structure validated
4. Report generated

**Output:** Validation summary

---

## Customization Options

### Adjust Video Resolution
```powershell
.\slide-generator.ps1 -Width 3840 -Height 2160  # 4K
.\slide-generator.ps1 -Width 1280 -Height 720   # HD
```

### Change Audio Voice
Edit `audio-generator.ps1`:
```powershell
[string]$Voice = "EXAVITQu4emMWXw3c5H5"  # Current: Professional male
# Or try: "21m00Tcm4TlvDq8ikWAM"  # Alternative: Female voice
```

### Modify Slide Appearance
Edit slide definitions in `slide-generator.ps1`:
```powershell
@{
    Number = 1
    Title = "ARROYO® 1K"
    Background = "#FFFFFF"        # White background
    TextColor = "#1a1a1a"         # Dark gray text
    Points = @( ... )
}
```

### Change Video Output Format
Edit `video-generator.ps1` FFmpeg command:
```powershell
# More compression (smaller file, lower quality)
-preset slow -crf 28

# Less compression (larger file, higher quality)
-preset slow -crf 18
```

---

## Troubleshooting

### ❌ "FFmpeg not found"
**Solution:**
1. Install FFmpeg from https://ffmpeg.org/download.html
2. Add to PATH: Edit Environment Variables
3. Test: `ffmpeg -version`

### ❌ "API key not valid"
**Solution:**
1. Get new API key from https://elevenlabs.io/account
2. Set environment variable: `$env:ELEVENLABS_API_KEY = "sk-..."`
3. Test: `$env:ELEVENLABS_API_KEY`

### ❌ "Script file not found"
**Solution:**
1. Verify you're in the correct directory: `C:\Users\Owner\Local Sites\mlcampbell\projects\product-videos\W14095\en\01 Essential Knowledge`
2. Check script.md exists: `ls *.md`
3. Run from the directory containing script.md

### ❌ Audio takes too long / fails
**Solution:**
1. Verify API key is valid: `$env:ELEVENLABS_API_KEY`
2. Check internet connection
3. Run specific slide test: `.\audio-generator.ps1 -Verbose`

### ❌ Video plays at wrong speed
**Solution:**
1. Verify audio duration matches slide timing
2. Check FFmpeg framerate setting (should be 1 for slides)
3. Use FFprobe to check actual duration: `ffprobe -v error -show_entries format=duration video.mp4`

---

## Video Specifications

| Property | Value |
|---|---|
| **Resolution** | 1920×1080 (FHD) |
| **Aspect Ratio** | 16:9 |
| **Frame Rate** | 1 fps (slide-based) |
| **Video Codec** | H.264 (libx264) |
| **Bitrate** | 5,000 kbps (5 Mbps) |
| **Audio Codec** | AAC |
| **Audio Bitrate** | 128 kbps |
| **Sample Rate** | 44.1 kHz |
| **Container** | MP4 |
| **Duration** | ~9 minutes |
| **File Size** | ~30-50 MB |

---

## Next Steps

### After Production Complete:
1. ✅ Review video for quality
2. ✅ Check audio-to-slide synchronization
3. ✅ Verify all 8 slides display correctly
4. ✅ Test playback in multiple players
5. ✅ Prepare for upload/distribution

### For Remaining Modules:
1. Repeat process for Module 02 (Application)
2. Repeat for Module 03 (Preparation)
3. Repeat for Module 04 (Troubleshooting)
4. Repeat for Module 05 (Environmental Knowledge)

### Integration with Main Pipeline:
1. Upload all 5 module videos to server
2. Create playlist combining all modules
3. Add subtitles/captions
4. Create training course catalog entry
5. Deploy to learning management system (LMS)

---

## Support & Resources

- **FFmpeg Documentation:** https://ffmpeg.org/documentation.html
- **ElevenLabs API Docs:** https://elevenlabs.io/docs
- **PowerShell Guide:** https://learn.microsoft.com/en-us/powershell/
- **Video Production Best Practices:** https://trac.ffmpeg.org/wiki/Scaling
- **Product Documentation:** See parent W14095 folder

---

## Summary

✅ **Ready to produce 8-10 minute professional training video**

**What You Have:**
- 8-slide training script with complete narratives
- 4 production scripts (audio, slides, video, orchestration)
- Full documentation and setup guides
- Professional video specifications

**What Gets Created:**
- 8 professional MP3 audio files
- 8 high-resolution slide images (1920×1080)
- 1 final MP4 video ready for distribution

**Time to Complete:** ~10-15 minutes (depends on internet speed for audio generation)

**Next Command to Run:**
```powershell
cd "C:\Users\Owner\Local Sites\mlcampbell\projects\product-videos\W14095\en\01 Essential Knowledge"
.\run-production.ps1
```

🚀 **Ready to produce!**
