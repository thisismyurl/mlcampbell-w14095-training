# ARROYO® 1K Training Content

This repository contains training video scripts and content for **ARROYO® 1K Waterborne White Topcoat**.

## 📝 Editing Scripts

Non-technical users can edit scripts directly on GitHub:

1. **Navigate to the script:** Go to `en/01 Essential Knowledge/script.md`
2. **Click the pencil icon (✏️)** in the top right to edit
3. **Make your changes** in the editor
4. **Scroll to bottom** and add a commit message describing your changes
5. **Click "Commit changes"** - your edits are saved!

### Quick Links for Editing
- [Edit Essential Knowledge Script](https://github.com/thisismyurl/mlcampbell-w14095-training/edit/main/en/01%20Essential%20Knowledge/script/script.md)

## 📁 Repository Structure

```
W14095/
├── en/                                  # English language content
│   ├── 01 Essential Knowledge/          # Module 1
│   │   ├── script/                      # Training scripts
│   │   │   └── script.md               # ✏️ EDIT THIS - Training narration
│   │   ├── video/                       # Generated video content
│   │   │   ├── audio/                   # Generated audio files
│   │   │   ├── slides/                  # Generated slide images
│   │   │   └── W14095-01-essential-knowledge.mp4  # Final video
│   │   ├── build-video.ps1             # Production script for this module
│   │   └── README.md                    # Module-specific guide
│   ├── 02 Application/                  # Module 2
│   ├── 03 Preparation/                  # Module 3
│   ├── audio-config.json               # Audio generation configuration
│   └── config.json                      # Language-specific settings
├── docs/                                # Product documentation
│   ├── EDS_Arroyo_1K.pdf
│   ├── PDS_Arroyo_1K.pdf
│   └── SDS_Arroyo_1K.pdf
└── W14095_product_data.json            # Product metadata
```

**Centralized Production Tools:**
```
C:\Users\Owner\Local Sites\mlcampbell\projects\video-tools\
├── audio-generator-v2.ps1              # TTS audio generation
├── slide-generator.ps1                 # Slide image creation
├── video-generator.ps1                 # Video assembly
└── VIDEO_GENERATION_INSTRUCTIONS.md    # Technical docs
```

## 🎯 What You Can Edit

### ✅ Safe to Edit
- **script/script.md files** - All training narration and content
- **README.md files** - Documentation and guides
- Any markdown (.md) files

### ⚠️ Please Don't Edit
- **build-video.ps1 files** - Module build scripts (unless you know PowerShell)
- **video/ folders** - Auto-generated content (audio, slides, videos)
- **.json files** - Configuration data (unless specifically instructed)

## 🎬 Video Production

Training scripts are converted to videos using centralized production tools:

**Tools Location:** `C:\Users\Owner\Local Sites\mlcampbell\projects\video-tools\`

**Process:**
1. **Text-to-Speech** - ElevenLabs AI converts script to audio
2. **Slide Generation** - Creates visual slides from content
3. **Video Assembly** - Combines audio + slides with FFmpeg

**To Build a Module:**
```powershell
cd "W14095\en\01 Essential Knowledge"
.\build-video.ps1
```

See module README files for detailed production guides.

## 📖 Script Writing Guidelines

See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Script formatting rules
- Writing best practices
- Technical terminology guidelines
- Quality standards

## 🔗 Related Resources
- [M.L. Campbell Product Catalog](https://mlcampbell.com)
- [ARROYO® Product Line](https://mlcampbell.com/arroyo)

## 📧 Support
Questions? Contact the training team or open an issue in this repository.

---

**Product:** ARROYO® 1K Waterborne White Topcoat (W14095)  
**Manufacturer:** M.L. Campbell  
**Updated:** January 2026
