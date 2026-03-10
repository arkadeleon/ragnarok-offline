# Repository Guidelines

This file gives Codex repository-specific guidance for working in `ragnarok-offline`.

## Project Overview

Ragnarok Offline is a multi-platform SwiftUI app for running Ragnarok Online completely offline. The app embeds the `swift-rathena` server stack in-process and layers a native SwiftUI client, database browser, simulators, and supporting tools on top.

Primary targets:
- iOS 18+
- macOS 15+
- visionOS 2+

The codebase mixes:
- A top-level Xcode app target in `RagnarokOffline/`
- Many local Swift packages in `Packages/`
- A Swift code generator in `RagnarokOfflineGenerator/`
- A separate optional HTTP resource server in `RagnarokOfflineRemoteClient/`
- The `swift-rathena/` submodule containing the C++ server and its SwiftPM wrapper

## High-Value Commands

### Main App
```bash
# Open the Xcode project
open RagnarokOffline.xcodeproj

# Main app test plan
# RagnarokOffline/RagnarokOffline.xctestplan
```

The app is primarily driven from Xcode. The shared scheme is `RagnarokOffline`.

### Code Generation
```bash
./generate.sh
```

`generate.sh` runs the generator in `RagnarokOfflineGenerator/` and updates:
- `Packages/RagnarokConstants/Sources/RagnarokConstants/Generated`
- `Packages/RagnarokPackets/Sources/RagnarokPackets/Generated`

Do not hand-edit generated files unless the user explicitly asks for it. Change the generator inputs or `swift-rathena` headers instead, then regenerate.

### Swift Package Builds
```bash
swift build --package-path Packages/RagnarokGame
swift build --package-path Packages/RagnarokNetwork
swift build --package-path Packages/RagnarokPackets
swift build --package-path Packages/RagnarokReality
swift build --package-path Packages/RagnarokRenderers
swift build --package-path Packages/RagnarokResources
```

Use targeted package builds when validating a local change. Prefer the smallest relevant build or test scope.

### Swift Package Tests
```bash
swift test --package-path Packages/RagnarokPackets
swift test --package-path Packages/RagnarokNetwork
swift test --package-path Packages/RagnarokFileFormats
```

### Remote Client
```bash
swift build --package-path RagnarokOfflineRemoteClient
swift test --package-path RagnarokOfflineRemoteClient
swift run --package-path RagnarokOfflineRemoteClient
```

### Generator
```bash
swift run --package-path RagnarokOfflineGenerator ragnarok-offline-generator
```

### swift-rathena
```bash
swift build --scratch-path "$PWD/.build" --package-path swift-rathena
swift test --package-path swift-rathena
```

`swift-rathena` is heavier than the pure Swift packages. Only rebuild it when the change actually touches the embedded server or generated packet/constant inputs.

## Repository Layout

### Main App

`RagnarokOffline/` contains the app target. Important areas:
- `App/` - platform entry points (`iOSApp.swift`, `macOSApp.swift`, `visionOSApp.swift`) and `AppModel.swift`
- `Main/` - top-level navigation and shell views
- `GameClient/` - game client UI
- `Database/` - database browsing UI
- `Server/` - embedded server controls and models
- `ChatClient/` - chat UI and session handling
- `CharacterSimulator/` - character preview and simulation
- `SkillSimulator/` - skill simulation UI
- `Files/` - file browsing and file-backed models
- `Core/` - reusable UI and rendering hosts
- `Settings/` - app settings models and views
- `Help/` - help content
- `Resources/` - bundled app resources

`RagnarokOfflineTests/` contains app-level tests.

### Local Swift Packages

Current packages under `Packages/`:
- `BinaryIO`
- `DataCompression`
- `GRF`
- `ImageRendering`
- `JSONViewer`
- `PerformanceMetric`
- `RagnarokConstants`
- `RagnarokDatabase`
- `RagnarokFileFormats`
- `RagnarokGame`
- `RagnarokLocalization`
- `RagnarokModels`
- `RagnarokNetwork`
- `RagnarokPackets`
- `RagnarokReality`
- `RagnarokRenderers`
- `RagnarokResources`
- `RagnarokSprite`
- `SGLMath`
- `TextEncoding`
- `ThumbstickView`
- `WorldCamera`

### Supporting Projects

- `RagnarokOfflineGenerator/` - Swift code generator for constants and packets
- `RagnarokOfflineRemoteClient/` - optional HTTP resource server
- `RagnarokOfflineThumbnailExtension/` - Finder/Quick Look thumbnails
- `swift-rathena/` - embedded server implementation and resources

## Architecture Notes

### App Model

`RagnarokOffline/App/AppModel.swift` is the central composition root. It owns:
- Resource directories for local, iCloud, and cached remote client data
- Embedded login/char/map/web server models
- Database browsing state
- Chat, game, character simulator, and skill simulator state

When a change affects app-wide resource loading or server lifecycle, inspect `AppModel` first.

### Embedded Server Stack

The app uses products from `swift-rathena/`:
- `rAthenaLogin`
- `rAthenaChar`
- `rAthenaMap`
- `rAthenaWeb`
- `rAthenaResources`

The working directory is prepared before server start and contains the SQLite database plus copied server resources. Changes to server bootstrap often touch both SwiftUI app code and `swift-rathena`.

### Data and Resources

Main data sources:
- GRF archives and client assets loaded through `RagnarokResources`
- YAML game databases parsed by `RagnarokDatabase`
- Localized display tables in `RagnarokLocalization`
- Generated constants and packet types in `RagnarokConstants` and `RagnarokPackets`

If you change packet definitions or C++ enums:
1. Edit `swift-rathena`
2. Run `./generate.sh`
3. Update Swift call sites
4. Run focused tests/builds

### Rendering and Game Logic

- `RagnarokGame` contains high-level session and map logic
- `RagnarokRenderers` contains Metal renderers
- `RagnarokReality` bridges content into RealityKit for visionOS
- `RagnarokSprite` handles 2D sprite composition
- `WorldCamera` and `ThumbstickView` support controls and camera behavior

## Working Rules

### Prefer Small Validation Steps

After changes, prefer:
- One relevant package build
- One relevant package test
- Xcode-only validation when the change is app-target-specific

Avoid defaulting to a full project-wide rebuild unless the change crosses multiple layers.

### Generated Code

Treat these as generated outputs:
- `Packages/RagnarokConstants/Sources/RagnarokConstants/Generated/**`
- `Packages/RagnarokPackets/Sources/RagnarokPackets/Generated/**`

Update their sources and regenerate instead of manually patching output.

### SwiftUI and Observation

The app uses modern SwiftUI with `@Observable` and `@MainActor` in key models. Match existing patterns before introducing a different state-management approach.

### Package-First Debugging

Many features are isolated in local packages. If a bug is clearly in parsing, networking, rendering, math, or localization, fix and validate at the package level before touching the app target.

### Keep Platform Behavior Intact

The app has separate entry points for iOS, macOS, and visionOS. Be careful with shared UI changes that might break:
- macOS multi-window behavior
- visionOS immersive flows
- iOS-specific presentation or input assumptions

## Common Change Patterns

### Adding or Changing Network Packets

1. Update packet definitions in `swift-rathena`
2. Run `./generate.sh`
3. Update handling in `RagnarokNetwork` sessions or `RagnarokGame`
4. Test packet encoding/decoding and affected flows

### Adding or Changing C++ Enums

1. Update the enum in `swift-rathena`
2. Run `./generate.sh`
3. Update any localization or UI mapping that depends on the new case

### Adding a New Database Type

1. Add or update schema/data in `swift-rathena/db`
2. Extend `RagnarokDatabase`
3. Add localized naming or display support if needed
4. Add browsing UI under `RagnarokOffline/Database`

### Adding Localization for a Constant Type

1. Add a table in `RagnarokLocalization`
2. Expose a `localizedName`-style API from the constant type or an extension
3. Add tests for the table lookup

### Modifying Resource Loading

Inspect:
- `Packages/RagnarokResources`
- `RagnarokOffline/App/AppModel.swift`
- `RagnarokOfflineRemoteClient/` if remote fallback behavior is involved

## Practical Notes for Agents

- Use `rg` for text/file discovery.
- Read package manifests when scoping impact; package boundaries are meaningful here.
- Expect changes in one layer to ripple into generated code, localization tables, or database browsing views.
- If a change touches `swift-rathena`, check whether generated Swift code also needs to move.
- If a change is only in a single package, avoid editing the Xcode project unless the user explicitly asks.
