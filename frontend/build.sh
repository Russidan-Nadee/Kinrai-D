#!/bin/bash
set -e

# Download and install Flutter
echo "Downloading Flutter SDK..."
curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz -o flutter.tar.xz

echo "Extracting Flutter SDK..."
tar xf flutter.tar.xz

echo "Setting up Flutter..."
export PATH="$PATH:`pwd`/flutter/bin"
flutter config --no-analytics

echo "Running Flutter doctor..."
flutter doctor

echo "Building Flutter web app..."
flutter build web --release --web-renderer canvaskit

echo "Build completed successfully!"
