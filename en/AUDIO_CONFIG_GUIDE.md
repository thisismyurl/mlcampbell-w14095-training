# Audio Configuration System

## Overview

The audio configuration system allows you to control how text is converted to speech, including:
- **Character filtering** - Remove symbols like ™, ®, © from audio
- **Pronunciation overrides** - Control how specific words are pronounced
- **Text cleaning** - Remove markdown formatting and special characters

## Configuration File

**Location:** `W14095/en/audio-config.json`

This file controls all audio generation behavior across all modules for this product.

## Quick Start

### 1. Basic Usage (Use Existing Config)

```powershell
cd "C:\Users\Owner\Local Sites\mlcampbell\projects\product-videos\W14095\en\01 Essential Knowledge"

# Use the new enhanced audio generator
.\audio-generator-v2.ps1

# See what text transformations are being applied
.\audio-generator-v2.ps1 -ShowCleaning

# Regenerate all audio with current config
.\audio-generator-v2.ps1 -Force
```

### 2. Add Custom Pronunciation Override

Edit `W14095/en/audio-config.json`:

```json
{
  "pronunciationOverrides": {
    "overrides": [
      {
        "original": "ARROYO",
        "replacement": "Uh-ROY-oh",
        "description": "Brand name pronunciation",
        "enabled": true,  // ← Change to true to activate
        "note": "Use only if TTS mispronounces"
      }
    ]
  }
}
```

### 3. Add New Custom Word

Add to the `customPronunciations` section:

```json
{
  "customPronunciations": {
    "examples": [
      {
        "original": "polyurethane",
        "replacement": "polly-yur-uh-thane",
        "enabled": true,
        "note": "TTS was rushing this word"
      }
    ]
  }
}
```

## Configuration Sections

### Character Filters

**Purpose:** Remove special characters that shouldn't be spoken

```json
"characterFilters": {
  "filters": [
    {
      "character": "™",
      "description": "Trademark symbol",
      "replacement": ""
    }
  ]
}
```

**Pre-configured filters:**
- `®` → (removed)
- `™` → (removed)
- `©` → (removed)
- `°` → " degrees"

### Pronunciation Overrides

**Purpose:** Replace words with phonetic spellings for better TTS

```json
"pronunciationOverrides": {
  "overrides": [
    {
      "original": "VOC",
      "replacement": "V O C",
      "description": "Volatile Organic Compounds acronym",
      "enabled": true
    }
  ]
}
```

**Pre-configured overrides:**
- `M.L. Campbell` → "M L Campbell"
- `1K` → "one K"
- `2K` → "two K"
- `VOC` → "V O C"
- `HVLP` → "H V L P"
- `SDS` → "S D S"
- `PDS` → "P D S"
- `EDS` → "E D S"
- `GREENGUARD` → "Green Guard"
- `AWI` → "A W I"
- `KCMA` → "K C M A"

### Text Cleaning Rules

**Purpose:** Remove markdown formatting

Pre-configured to remove:
- Bold markers (`**`)
- Code markers (`` ` ``)
- Link brackets (`[]`)
- Horizontal rules (`---`)
- Headers (`##`)

## Usage Examples

### Example 1: Test Pronunciation Changes

```powershell
# See how text is being cleaned before generating audio
.\audio-generator-v2.ps1 -ShowCleaning -Force

# Output shows:
# 📝 Original text:
#    The ARROYO® 1K system reduces VOC emissions by 50%...
# 🧹 Cleaned text:
#    The Uh-ROY-oh one K system reduces V O C emissions by 50 percent...
```

### Example 2: Add Industry Jargon Override

If the TTS mispronounces "tannin", add this to `audio-config.json`:

```json
{
  "original": "tannin",
  "replacement": "TAN-nin",
  "enabled": true,
  "note": "TTS was saying 'tan-NEEN'"
}
```

Then regenerate:

```powershell
.\audio-generator-v2.ps1 -Force
```

### Example 3: Product-Specific Words

For product names that need special pronunciation:

```json
{
  "original": "MagnaMax",
  "replacement": "MAGNA max",
  "enabled": true,
  "note": "Emphasize first syllable"
}
```

## Testing Workflow

1. **Run with -ShowCleaning** to see transformations:
   ```powershell
   .\audio-generator-v2.ps1 -ShowCleaning -Force
   ```

2. **Listen to generated audio** and identify mispronunciations

3. **Edit audio-config.json** to add overrides

4. **Regenerate specific slide** to test:
   ```powershell
   # Delete one audio file to regenerate just that slide
   Remove-Item ".\audio\slide-05.mp3"
   .\audio-generator-v2.ps1
   ```

5. **Regenerate all** once satisfied:
   ```powershell
   .\audio-generator-v2.ps1 -Force
   ```

## Tips & Best Practices

### When to Use Pronunciation Overrides

✅ **DO use for:**
- Acronyms (VOC, HVLP, SDS)
- Brand names (if mispronounced)
- Technical terms (if mispronounced)
- Numbers with letters (1K, 2K)
- Company names (M.L. Campbell)

❌ **DON'T use for:**
- Words that sound natural already
- Every single term (keep it minimal)
- Common words (TTS handles these well)

### Phonetic Spelling Tips

- **Acronyms:** Add spaces between letters: `"V O C"` not `"vee-oh-see"`
- **Emphasis:** Use CAPS for stressed syllables: `"MAG-na-max"`
- **Natural flow:** Read your phonetic spelling aloud to test it
- **Hyphens:** Use to separate syllables: `"poly-yur-uh-thane"`

### Character Filtering

The `™` and `®` symbols are automatically removed from audio but stay in your script.md file for visual display. This is intentional - you want them in slides but not spoken.

## Troubleshooting

### Problem: Override Not Working

**Solution:** Check that `"enabled": true` is set

### Problem: Partial Word Replacement

The system uses word boundary matching (`\b`), so "VOC" won't match "VOCALS".

If you need partial matching, you'll need to modify the replacement pattern in the script.

### Problem: Config Not Loading

**Error:** "Config file not found"

**Solution:** Make sure `audio-config.json` is in the parent directory (`W14095/en/`) not in the module folder.

### Problem: Want Module-Specific Config

Currently, config is shared across all modules for a product. If you need module-specific pronunciation:

1. Copy `audio-config.json` to the module folder
2. Run: `.\audio-generator-v2.ps1 -ConfigPath ".\audio-config.json"`

## Migration from Old Script

The new `audio-generator-v2.ps1` is backward compatible. Your old `audio-generator.ps1` still works.

**To switch:**

1. Use `audio-generator-v2.ps1` instead of `audio-generator.ps1`
2. Config is optional - works with or without `audio-config.json`
3. All same parameters supported (`-Force`, `-Voice`, `-ApiKey`)

## Configuration Template

Copy this to create a new product's audio config:

```json
{
  "description": "Audio generation configuration",
  "version": "1.0",
  
  "characterFilters": {
    "filters": [
      {"character": "®", "replacement": ""},
      {"character": "™", "replacement": ""},
      {"character": "©", "replacement": ""},
      {"character": "°", "replacement": " degrees"}
    ]
  },
  
  "pronunciationOverrides": {
    "overrides": [
      {"original": "M.L. Campbell", "replacement": "M L Campbell", "enabled": true},
      {"original": "VOC", "replacement": "V O C", "enabled": true}
    ]
  },
  
  "customPronunciations": {
    "examples": []
  }
}
```

## Support

If you discover pronunciation issues:
1. Document the word and how it should sound
2. Add to `customPronunciations` with a note
3. Test with `-ShowCleaning` flag
4. Regenerate with `-Force`
