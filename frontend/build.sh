#!/bin/bash

set -e

echo "============================================"
echo "Flutter Web Build for Vercel"
echo "============================================"

# Set API_URL from environment or use default
API_URL=${API_URL:-"https://kinrai-d-production.up.railway.app"}
echo "API_URL: $API_URL"

# Install Flutter if not exists
if [ ! -d "$HOME/.flutter" ]; then
    echo "Cloning Flutter SDK..."
    git clone https://github.com/flutter/flutter.git $HOME/.flutter --depth=1
fi

# Add Flutter to PATH
export PATH="$PATH:$HOME/.flutter/bin"

# Enable web
echo "Enabling Flutter web..."
flutter config --enable-web

# Get dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Build
echo "Building Flutter web..."
flutter build web --release --dart-define=API_URL=$API_URL

echo "============================================"
echo "Build completed successfully!"
echo "============================================"
