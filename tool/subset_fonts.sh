#!/bin/bash
set -e

# Directory setup
ASSETS_DIR="assets/fonts"
mkdir -p "$ASSETS_DIR"

# Check for fonttools
if ! command -v pyftsubset &> /dev/null; then
    echo "pyftsubset not found. Installing fonttools..."
    pip3 install fonttools brotli
fi

# Character set file
# Character set files check
check_chars_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "Error: $file not found. Run 'dart run tool/extract_chars.dart' first."
        exit 1
    fi
}

# Cache directory setup
CACHE_DIR=".cache/fonts"
mkdir -p "$CACHE_DIR"
echo "Using cache dir: $CACHE_DIR"

subset_font() {
    local url="$1"
    local output_name="$2"
    local chars_file="$3"
    local internal_zip_file="$4"

    check_chars_file "$chars_file"

    local filename=$(basename "$url")
    local extension="${filename##*.}"
    local source_filename="${output_name%.*}-Source.${extension}"
    local cached_file="$CACHE_DIR/$source_filename"

    if [ -f "$cached_file" ]; then
        echo "Using cached $filename"
    else
        echo "Downloading $url..."
        curl -f -L -o "$cached_file" "$url"
    fi

    local font_file="$cached_file"
    if [[ "$filename" == *.zip ]]; then
        echo "Extracting zip..."
        unzip -j -o "$cached_file" -d "$CACHE_DIR"

        if [ -n "$internal_zip_file" ]; then
             font_file="$CACHE_DIR/$internal_zip_file"
        else
             # Fallback: specific logic for HaSta
             font_file=$(find "$CACHE_DIR" -name "*HaSta.ttf" | head -n 1)
        fi

        if [ ! -f "$font_file" ]; then
            echo "Error: Could not find extracted font file '$internal_zip_file' in $CACHE_DIR"
            exit 1
        fi
    fi

    echo "Subsetting to $output_name using $chars_file..."

    # --layout-features='*' keeps OpenType features.
    # --no-hinting reduces size.
    # --desubroutinize for compatibility.
    # For variable fonts, pyftsubset retains variations by default unless tables are dropped.

    pyftsubset "$font_file" \
        --text-file="$chars_file" \
        --unicodes="U+0020-007E" \
        --output-file="$ASSETS_DIR/$output_name" \
        --layout-features='*' \
        --no-hinting \
        --no-recalc-timestamp \
        --desubroutinize

    echo "Created $ASSETS_DIR/$output_name"
}

# Noto Sans Variable (Latin)
subset_font "https://github.com/google/fonts/raw/main/ofl/notosans/NotoSans%5Bwdth%2Cwght%5D.ttf" \
    "NotoSans-Variable.ttf" \
    "characters_NotoSans.txt"

# Noto Sans Tamil Variable
subset_font "https://github.com/google/fonts/raw/main/ofl/notosanstamil/NotoSansTamil%5Bwdth%2Cwght%5D.ttf" \
    "NotoSansTamil-Variable.ttf" \
    "characters_NotoSansTamil.txt"

# Noto Sans SC (Simplified Chinese) Variable
subset_font "https://github.com/google/fonts/raw/main/ofl/notosanssc/NotoSansSC%5Bwght%5D.ttf" \
    "NotoSansSC-Variable.ttf" \
    "characters_NotoSansSC.txt"

# Noto Sans TC (Traditional Chinese) Variable
subset_font "https://github.com/google/fonts/raw/main/ofl/notosanstc/NotoSansTC%5Bwght%5D.ttf" \
    "NotoSansTC-Variable.ttf" \
    "characters_NotoSansTC.txt"

# Noto Sans JP (Japanese) Variable
subset_font "https://github.com/google/fonts/raw/main/ofl/notosansjp/NotoSansJP%5Bwght%5D.ttf" \
    "NotoSansJP-Variable.ttf" \
    "characters_NotoSansJP.txt"

# Klingon HaSta (Static)
subset_font "https://www.evertype.com/fonts/tlh/klingon-piqad-hasta.zip" \
    "Klingon-pIqaD-HaSta.ttf" \
    "characters_KlingonHaSta.txt"

# Alcarin Tengwar (Variable)
subset_font "https://github.com/Tosche/Alcarin-Tengwar/raw/main/Fonts%20Variable/AlcarinTengwarVF.ttf" \
    "AlcarinTengwar.ttf" \
    "characters_AlcarinTengwar.txt"

# Aurebesh (AurekFonts)
subset_font "https://aurekfonts.github.io/AurebeshAF/AurebeshAF.zip" \
    "AurebeshAF-Canon.otf" \
    "characters_Aurebesh.txt" \
    "AurebeshAF-Canon.otf"

# Mando'a (AurekFonts)
subset_font "https://aurekfonts.github.io/MandoAF/MandoAF.zip" \
    "MandoAF-Regular.otf" \
    "characters_MandoAF.txt" \
    "MandoAF-Regular.otf"

# Clean up
# rm -rf "$TEMP_DIR"
echo "Done! Fonts are in $ASSETS_DIR"
ls -lh "$ASSETS_DIR"
