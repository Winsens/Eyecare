
# Eyecare - A native macOS eye-care and blue-light filter built for Apple Silicon

[![Platform](https://img.shields.io/badge/Platform-macOS%2014.0%2B-blue)](https://apple.com)
[![Architecture](https://img.shields.io/badge/Architecture-Apple%20Silicon%20(ARM64)-orange)](https://apple.com)
[![Language](https://img.shields.io/badge/Language-Swift%206-green)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-purple)](LICENSE)

A native macOS eye-care, blue-light filter and screen dimming tool tailored for Apple Silicon (M1/M2/M3/M4/M5 chips). Only **400 KB** in size, **0.0% CPU usage**, and no third-party dependencies.

---

## 🌟 Key Features

1. **100% native Apple Silicon (ARM64)**
   * Compiled natively with Swift + AppKit + SwiftUI. No Rosetta 2 translation, which avoids compatibility issues on macOS 28 and later.
2. **Multiple blue-light filter modes**
   * **Daily Warm (~3400K)**: soft, light warm tone that removes harsh white light with almost no impact on everyday office work or code colors.
   * **Deep Care (~2700K)**: warm amber gold that helps relieve dry, tired and sore eyes during long sessions.
   * **Candlelight (~1900K)**: deep warm candlelight for dark rooms and late nights, eliminating harsh glare.
   * **Soft Green**: classic paper-like soft green mode that gently eases eye fatigue.
3. **Sub-zero screen dimming**
   * Below the Mac's lowest hardware brightness, keep dimming the screen smoothly in software (0% ~ 50%) so it's comfortable late at night.
4. **Full mouse pass-through (event pass-through)**
   * Uses a high-level, hardware-accelerated window overlay. All mouse clicks, scrolls and drags pass straight through, with zero latency and nothing in the way.
   * Full support for multi-display hot-plugging and automatic following.
5. **20-20-20 eye-break reminders**
   * Built-in 20-20-20 timer that periodically prompts you to look into the distance for 20 seconds, with a full-screen "breathing" eye-relaxation view (press Esc to exit at any time).
6. **Clean menu bar app**
   * Minimal menu bar presence (doesn't take up space in the Dock), with launch at login support.

---

## 🛠️ Tech Stack & Building

### Toolchain
* **Language**: Apple Swift 6
* **UI frameworks**: SwiftUI + AppKit (Cocoa)
* **Graphics**: CoreAnimation (CALayer) hardware-accelerated layers
* **Service management**: ServiceManagement (SMAppService)
* **Compiler**: Apple `swiftc` (no need for the full Xcode IDE; the Command Line Tools are enough to build in seconds)

### One-step build

```bash
# 1. Clone this repository
git clone https://github.com/your-username/Eyecare.git
cd Eyecare

# 2. Make the script executable and build
chmod +x build.sh
./build.sh

# 3. Install to the Applications folder
cp -R "Eyecare.app" /Applications/
```

---

## 📄 Source Layout

```text
├── src/
│   ├── main.swift                  # Program entry point and lifecycle
│   ├── AppDelegate.swift           # Menu bar StatusItem and popover controller
│   ├── Models.swift                # Filter presets, settings persistence and AppState
│   ├── DisplayFilterManager.swift  # Hardware gamma LUT filter for all displays, plus the eye-break overlay
│   ├── RestReminderView.swift      # 20-20-20 full-screen breathing relaxation view
│   ├── RestTimerManager.swift      # Eye-break reminder timer and launch-at-login service
│   └── ContentView.swift           # Modern SwiftUI menu bar control panel
├── AppIcon.icns                    # 1024x1024 original macOS squircle icon
├── Info.plist                      # Bundle metadata
├── build.sh                        # One-step build and packaging script
├── LICENSE                         # MIT license
└── README.md
```

---

## ⚖️ License & Copyright

This project is fully open source under the **MIT License**.
* All Swift source code in this project is an **independent, newly written clean-room implementation** and contains no code or reverse-engineered assets from any older commercial software.
* The icon `AppIcon.icns` is an independently created 1024x1024 high-resolution vector asset with no third-party intellectual property concerns.
* PRs and issues are welcome!
