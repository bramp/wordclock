# Natural Languages

This directory contains definitions and time-to-words logic for natural languages spoke on Earth.

## Language and Font Mapping

For natural languages, we primarily use the **Noto Sans** family from Google Fonts. This ensures consistent aesthetics while providing broad glyph coverage across different scripts.

| Language / Script | Language Code | Font Family | Asset File |
| :--- | :--- | :--- | :--- |
| **Most (Latin, Cyrillic, Greek, Hebrew)** | `en`, `de`, `ru`, `el`, `he`, etc. | [Noto Sans](https://fonts.google.com/specimen/Noto+Sans) | `NotoSans-Regular.ttf`, `NotoSans-Bold.ttf` |
| **Tamil** | `ta` | [Noto Sans Tamil](https://fonts.google.com/specimen/Noto+Sans+Tamil) | `NotoSansTamil-Regular.ttf`, `NotoSansTamil-Bold.ttf` |
| **Japanese** | `ja` | [Noto Sans JP](https://fonts.google.com/specimen/Noto+Sans+JP) | `NotoSansJP-Regular.ttf`, `NotoSansJP-Bold.ttf` |
| **Chinese (Simplified)** | `zh-Hans` | [Noto Sans SC](https://fonts.google.com/specimen/Noto+Sans+SC) | `NotoSansSC-Regular.ttf`, `NotoSansSC-Bold.ttf` |
| **Chinese (Traditional)** | `zh-Hant` | [Noto Sans TC](https://fonts.google.com/specimen/Noto+Sans+TC) | `NotoSansTC-Regular.ttf`, `NotoSansTC-Bold.ttf` |

## Offline Font Subsetting

To minimize app size, all fonts are subsetted to only include the characters used in the application. This is handled by the `tool/subset_fonts.sh` script, which uses `pyftsubset` to create the optimized `.ttf` files found in `assets/fonts/`.

If you add a new language or characters, you must run:
1. `dart run tool/extract_chars.dart`
2. `./tool/subset_fonts.sh`

## Structure

Each language is typically split into two files:
- `<language>.dart`: Contains the `WordClockLanguage` definition and generated grids.
- `<language>_time_to_words.dart`: Contains the logic for converting a `DateTime` into words.
