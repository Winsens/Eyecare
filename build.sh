#!/bin/bash
set -e

APP_NAME="Eyecare"
BUNDLE_ID="com.zep.eyecare"
BUILD_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"

echo "==> 🚀 Building ${APP_NAME} (Apple Silicon ARM64, hardware Gamma LUT engine)..."

# 1. Compile Swift sources
swiftc -O -target arm64-apple-macos14.0 \
  "${BUILD_DIR}/src/Models.swift" \
  "${BUILD_DIR}/src/DisplayFilterManager.swift" \
  "${BUILD_DIR}/src/RestReminderView.swift" \
  "${BUILD_DIR}/src/RestTimerManager.swift" \
  "${BUILD_DIR}/src/ContentView.swift" \
  "${BUILD_DIR}/src/AppDelegate.swift" \
  "${BUILD_DIR}/src/main.swift" \
  -o "${BUILD_DIR}/${APP_NAME}"

echo "==> 📦 Packaging macOS application bundle..."
rm -rf "${APP_BUNDLE}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

cp "${BUILD_DIR}/${APP_NAME}" "${APP_BUNDLE}/Contents/MacOS/"
cp "${BUILD_DIR}/Info.plist" "${APP_BUNDLE}/Contents/"
cp "${BUILD_DIR}/AppIcon.icns" "${APP_BUNDLE}/Contents/Resources/"

echo "==> 🔏 Signing app (ad-hoc signature)..."
codesign --force --deep --sign - "${APP_BUNDLE}"

echo "==> ✅ Build complete! Output: ${APP_BUNDLE}"
echo "==> Double-click to run, or copy it to /Applications/."
