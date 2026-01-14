# Audio Generation - Quick Reference

## ✅ What's Been Implemented

### 1. Configuration System
**File:** `W14095/en/audio-config.json`
- Character filtering (™, ®, © automatically removed from audio)
- Pronunciation overrides (12 pre-configured)
- Custom pronunciation section (for you to add as needed)
- Text cleaning rules (markdown removal)

### 2. Enhanced Audio Generator
**File:** `audio-generator-v2.ps1` (in each module folder)
- Reads configuration from parent directory
- Applies all filters and overrides
- Shows before/after with `-ShowCleaning`
- Backward compatible with old scripts

## 🚀 How to Use

### Regenerate Audio with Current Config
```powershell
cd "W14095\en\01 Essential Knowledge"
.\audio-generator-v2.ps1 -Force
```

### See What's Being Changed
```powershell
.\audio-generator-v2.ps1 -ShowCleaning -Force
```

### Add a New Pronunciation Override

1. **Edit:** `W14095\en\audio-config.json`

2. **Add to customPronunciations section:**
```json
{
  "original": "polyurethane",
  "replacement": "polly-yur-uh-thane",
  "enabled": true,
  "note": "TTS was rushing this word"
}
```

3. **Test one slide:**
```powershell
Remove-Item "audio\slide-03.mp3"
.\audio-generator-v2.ps1 -ShowCleaning
```

4. **Regenerate all if good:**
```powershell
.\audio-generator-v2.ps1 -Force
```

## 📋 Pre-Configured Overrides

Already set up and enabled:
- `M.L. Campbell` → "M L Campbell"
- `1K` → "one K"
- `VOC` → "V O C"
- `HVLP` → "H V L P"
- `SDS` / `PDS` / `EDS` → "S D S" / "P D S" / "E D S"
- `GREENGUARD` → "Green Guard"
- `AWI` → "A W I"
- `KCMA` → "K C M A"

Disabled by default (enable if needed):
- `ARROYO` → "Uh-ROY-oh"

## 🎯 Common Tasks

### Remove More Characters
Edit `characterFilters.filters` section:
```json
{
  "character": "→",
  "description": "Arrow symbol",
  "replacement": "to"
}
```

### Change Degree Symbol Behavior
Already configured: `°` → " degrees"

### Override a Mispronounced Brand Name
1. Find it in script with `-ShowCleaning`
2. Add to `customPronunciations`
3. Set `"enabled": true`
4. Regenerate with `-Force`

## 💡 Tips

- Keep visual symbols (™, ®) in your script.md - they're auto-filtered from audio
- Test changes with `-ShowCleaning` before regenerating everything
- Add notes to your overrides so you remember why you added them
- Use CAPS for emphasis: "MAGNA-max"
- Use spaces for acronyms: "V O C" not "voc"

## 📂 File Locations

```
W14095/
└── en/
    ├── audio-config.json           ← Edit this to change behavior
    ├── AUDIO_CONFIG_GUIDE.md       ← Full documentation
    └── 01 Essential Knowledge/
        ├── audio-generator-v2.ps1  ← Use this (new)
        └── audio-generator.ps1     ← Still works (old)
```

## 🔧 Migration Path

Your old `audio-generator.ps1` still works. To use the new system:

1. Use `audio-generator-v2.ps1` instead
2. Same parameters work (`-Force`, `-Voice`, `-ApiKey`)
3. Config is optional - works without it too

## Need Help?

See full documentation in: `W14095/en/AUDIO_CONFIG_GUIDE.md`
