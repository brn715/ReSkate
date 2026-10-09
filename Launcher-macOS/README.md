# ReSkate Launcher (macOS)

Native macOS SwiftUI companion that drives the Windows ReSkate launcher running inside CrossOver (or CrossOver Preview / FEX) bottles.

## What it does

- Discovers CrossOver + Preview installs and enumerates bottles
- Locates `C:\ReSkate\ReSkateLauncher.exe` in each bottle
- Streams `logs/ReSkate.log` live for status
- "PLAY" button that launches the game in the chosen bottle
- Per-bottle toggle of Advanced Settings flags (D3DMetal / DXVK, MSync, DLSS, High Resolution Mode)
- Thunderstore mod browser: search, install, delete from the bottle's `Mods/` folder
- Auto-checks ReSkate and game versions against the pinned build

## Why

The stock launcher is a Windows x64 ImGui executable. On Mac it runs through CrossOver, so its UI is aliased, DPI-blind, and generally a poor citizen. This app is native macOS: it does everything the stock launcher does that doesn't require being inside the Windows process, and delegates the rest (the actual game launch) to a one-line `wine --bottle X --cx-app ReSkateLauncher.exe --no-gui`.

## Target

- **macOS 14 Sonoma+**
- **Swift 5.9**
- **SwiftUI + Swift Concurrency** (no Combine)
- No third-party deps at first; pure Foundation + AppKit bridging where needed

## Layout

```
Launcher-macOS/
├── Package.swift                  # SwiftPM — app lives here
├── Sources/
│   ├── App/                       # @main entry, App struct, scene config
│   ├── Models/                    # Bottle, GameInstall, Mod — Codable structs
│   ├── Services/
│   │   ├── CrossOver.swift        # bottle inventory
│   │   ├── WineProcess.swift      # spawn/attach to wine subprocesses
│   │   ├── LogTailer.swift        # async stream of log lines
│   │   ├── GitHub.swift           # release check client
│   │   └── Thunderstore.swift     # mod API client
│   └── Views/
│       ├── Screens/               # RootView, BottleSetupView, PlayView, ModsView
│       └── Components/
├── Resources/                     # Assets.xcassets, app icon
└── Tests/
```

## Build

```sh
cd Launcher-macOS
swift build
swift run
```

Or open in Xcode via generated project (we'll provide after SwiftPM stabilises).
