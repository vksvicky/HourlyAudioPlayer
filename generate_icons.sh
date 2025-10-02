#!/bin/bash

# Script to generate app icons from a source image
# Usage: ./generate_icons.sh source_image.png

if [ $# -eq 0 ]; then
    echo "Usage: $0 <source_image.png>"
    echo "Example: $0 app_icon_source.png"
    exit 1
fi

SOURCE_IMAGE="$1"
ICON_DIR="Assets.xcassets/AppIcon.appiconset"

# Check if source image exists
if [ ! -f "$SOURCE_IMAGE" ]; then
    echo "Error: Source image '$SOURCE_IMAGE' not found!"
    exit 1
fi

# Check if sips command is available (macOS built-in image processing)
if ! command -v sips &> /dev/null; then
    echo "Error: sips command not found. This script requires macOS."
    exit 1
fi

echo "Generating app icons from: $SOURCE_IMAGE"
echo "Output directory: $ICON_DIR"

# Create icon directory if it doesn't exist
mkdir -p "$ICON_DIR"

# Generate all required icon sizes
echo "Generating 16x16@1x (16x16)..."
sips -z 16 16 "$SOURCE_IMAGE" --out "$ICON_DIR/icon_16x16.png"

echo "Generating 16x16@2x (32x32)..."
sips -z 32 32 "$SOURCE_IMAGE" --out "$ICON_DIR/icon_16x16@2x.png"

echo "Generating 32x32@1x (32x32)..."
sips -z 32 32 "$SOURCE_IMAGE" --out "$ICON_DIR/icon_32x32.png"

echo "Generating 32x32@2x (64x64)..."
sips -z 64 64 "$SOURCE_IMAGE" --out "$ICON_DIR/icon_32x32@2x.png"

echo "Generating 128x128@1x (128x128)..."
sips -z 128 128 "$SOURCE_IMAGE" --out "$ICON_DIR/icon_128x128.png"

echo "Generating 128x128@2x (256x256)..."
sips -z 256 256 "$SOURCE_IMAGE" --out "$ICON_DIR/icon_128x128@2x.png"

echo "Generating 256x256@1x (256x256)..."
sips -z 256 256 "$SOURCE_IMAGE" --out "$ICON_DIR/icon_256x256.png"

echo "Generating 256x256@2x (512x512)..."
sips -z 512 512 "$SOURCE_IMAGE" --out "$ICON_DIR/icon_256x256@2x.png"

echo "Generating 512x512@1x (512x512)..."
sips -z 512 512 "$SOURCE_IMAGE" --out "$ICON_DIR/icon_512x512.png"

echo "Generating 512x512@2x (1024x1024)..."
sips -z 1024 1024 "$SOURCE_IMAGE" --out "$ICON_DIR/icon_512x512@2x.png"

echo "Updating Contents.json..."

# Update Contents.json with the generated icon files
cat > "$ICON_DIR/Contents.json" << 'EOF'
{
  "images" : [
    {
      "filename" : "icon_16x16.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_16x16@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_32x32.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_32x32@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_128x128.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_128x128@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_256x256.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_256x256@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_512x512.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "512x512"
    },
    {
      "filename" : "icon_512x512@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "512x512"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

echo "✅ App icons generated successfully!"
echo ""
echo "Generated files:"
ls -la "$ICON_DIR"/*.png
echo ""
echo "Next steps:"
echo "1. Save your source image as 'app_icon_source.png' in the project root"
echo "2. Run: chmod +x generate_icons.sh && ./generate_icons.sh app_icon_source.png"
echo "3. Build and run the app to see your new icon!"
