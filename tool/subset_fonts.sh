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
CHARS_FILE="characters.txt"
if [ ! -f "$CHARS_FILE" ]; then
    echo "Error: $CHARS_FILE not found. Run 'dart run tool/extract_chars.dart' first."
    exit 1
fi

# Cache directory setup
CACHE_DIR=".cache/fonts"
mkdir -p "$CACHE_DIR"
echo "Using cache dir: $CACHE_DIR"

subset_font() {
    local url="$1"
    local output_name="$2"
    local filename=$(basename "$url")
    # For GitHub raw links with query params or encoded chars, filename might be ugly, but curl handles it.
    # We'll explicitly save to a simple name in cache based on the output name to avoid collisions or weird chars.
    # Actually, let's just hash the URL or use the output_name prefix + source.
    local source_filename="${output_name%.*}-Source.ttf"
    local cached_file="$CACHE_DIR/$source_filename"

    if [ -f "$cached_file" ]; then
        echo "Using cached $source_filename"
    else
        echo "Downloading $url..."
        curl -f -L -o "$cached_file" "$url"
    fi

    echo "Subsetting to $output_name..."
    # --unicodes="U+0020-007E" covers Basic Latin (ASCII)
    # --text-file="$CHARS_FILE" covers specific extracted characters
    # --layout-features='*' keeps OpenType features (like ligatures if needed)
    # --no-hinting reduces size
    # --desubroutinize for compatibility

    pyftsubset "$cached_file" \
        --text-file="$CHARS_FILE" \
        --unicodes="U+0020-007E" \
        --output-file="$ASSETS_DIR/$output_name" \
        --layout-features='*' \
        --no-hinting \
        --desubroutinize

    echo "Created $ASSETS_DIR/$output_name"
}

# Static Fonts from Noto Fonts GitHub (more reliable for static weights)
subset_font "https://github.com/notofonts/noto-fonts/raw/master/unhinted/ttf/NotoSans/NotoSans-Regular.ttf" "NotoSans-Regular.ttf"
subset_font "https://github.com/notofonts/noto-fonts/raw/master/unhinted/ttf/NotoSans/NotoSans-Medium.ttf" "NotoSans-Medium.ttf"
subset_font "https://github.com/notofonts/noto-fonts/raw/master/unhinted/ttf/NotoSans/NotoSans-Bold.ttf" "NotoSans-Bold.ttf"

# Noto Sans Tamil Variable
# We just use the regular weight from the variable font and copy it to others for now.
# Realistically we should use --variations="wght=700" etc but regular is usually enough for a subset.
subset_font "https://github.com/google/fonts/raw/main/ofl/notosanstamil/NotoSansTamil%5Bwdth%2Cwght%5D.ttf" "NotoSansTamil-Regular.ttf"
cp "$ASSETS_DIR/NotoSansTamil-Regular.ttf" "$ASSETS_DIR/NotoSansTamil-Bold.ttf"

# Noto Sans SC (Simplified Chinese) Variable
subset_font "https://github.com/google/fonts/raw/main/ofl/notosanssc/NotoSansSC%5Bwght%5D.ttf" "NotoSansSC-Regular.ttf"
cp "$ASSETS_DIR/NotoSansSC-Regular.ttf" "$ASSETS_DIR/NotoSansSC-Bold.ttf"

# Noto Sans TC (Traditional Chinese) Variable
subset_font "https://github.com/google/fonts/raw/main/ofl/notosanstc/NotoSansTC%5Bwght%5D.ttf" "NotoSansTC-Regular.ttf"
cp "$ASSETS_DIR/NotoSansTC-Regular.ttf" "$ASSETS_DIR/NotoSansTC-Bold.ttf"

# Noto Sans JP (Japanese) Variable
subset_font "https://github.com/google/fonts/raw/main/ofl/notosansjp/NotoSansJP%5Bwght%5D.ttf" "NotoSansJP-Regular.ttf"
# Copy JP regular to bold as a fallback
cp "$ASSETS_DIR/NotoSansJP-Regular.ttf" "$ASSETS_DIR/NotoSansJP-Bold.ttf"

# Klingon pIqaD
subset_font "https://hol.kag.org/pIqaD.ttf" "pIqaD.ttf"

# Clean up
# rm -rf "$TEMP_DIR"
echo "Done! Fonts are in $ASSETS_DIR"
ls -lh "$ASSETS_DIR"
