dart run flutter_launcher_icons

# Add some extra flutter_launcher_icons doesn't support
cp assets/favicon.svg web/icons/favicon.svg
convert -background none -resize 96x96 assets/favicon.svg web/icons/favicon-96x96.png
convert -background none -resize 48x48 assets/favicon.svg web/favicon.ico
convert -background none -resize 180x180 assets/favicon.svg web/icons/apple-touch-icon.png
