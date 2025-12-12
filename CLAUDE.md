# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ragnarok Offline is a multi-platform (iOS 18+, macOS 15+, visionOS 2+) SwiftUI application that runs the classic MMORPG Ragnarok Online completely offline. The app embeds the rAthena server (written in C++) to provide a single-player experience without requiring external servers.

## Build and Development Commands

### Building the Main Application
```bash
# Open Xcode project
open RagnarokOffline.xcodeproj

# Build and run in Xcode - use the "RagnarokOffline" scheme
# The app supports iOS, macOS, and visionOS targets
```

### Code Generation
```bash
# Regenerate Swift constants and packet definitions from C++ headers
./generate.sh

# This runs two commands:
# 1. generate-constants: C++ enums → Swift enums in RagnarokConstants/Generated/
# 2. generate-packets: C++ packet structs → Swift structs in RagnarokPackets/Generated/
```

### Testing
```bash
# Run all tests via Xcode
# Use the test plan: RagnarokOffline.xctestplan
# This includes tests from all packages (20+ test targets)

# Test individual packages with SPM
cd Packages/RagnarokNetwork
swift test

cd Packages/RagnarokFileFormats
swift test
```

### Remote Client Server (Optional)
```bash
# The remote client serves game resources over HTTP when local data.grf is unavailable
cd RagnarokOfflineRemoteClient
swift build
swift run

# Tests
swift test
```

## Architecture Overview

### Multi-Layer Package Architecture

The codebase uses 20+ Swift Package Manager packages organized in layers:

**Low-Level Utilities:**
- `BinaryIO` - Binary data reading/writing primitives
- `DataCompression` - Compression/decompression
- `TextEncoding` - Character encoding (EUC-KR, Shift-JIS)
- `SGLMath` - 3D math operations
- `PerformanceMetric` - Performance monitoring

**File Format Layer:**
- `GRF` - Reads Gravity Resource Format (game asset archives)
- `RagnarokFileFormats` - Parses Ragnarok file formats:
  - ACT (sprite actions/animations), SPR (sprite images)
  - RSW (world/map resources), RSM (3D models)
  - GND (ground mesh), GAT (ground altitude/walkability)
  - STR (effect animations), PAL, IMF, INI

**Resource Management:**
- `RagnarokResources` - Unified resource loading from local files, GRF archives, or remote URLs
  - Includes ResourceManager, caching layer, resource lookup tables
  - Lua script execution context for resource tables

**Data Layer:**
- `RagnarokDatabase` - YAML-based game database parsing (items, jobs, monsters, skills, etc.)
  - Uses RapidYAML to parse rAthena database files
  - Supports Renewal and Pre-Renewal game modes
- `RagnarokConstants` - Generated Swift enums from C++ (JobID, SkillID, ItemType, etc.)

**Networking Layer:**
- `RagnarokNetwork` - Client-server networking
  - `RagnarokPackets` - Packet definitions (generated from C++ structs)
  - Client using NWConnection with async/await
  - Sessions: LoginSession, CharSession, MapSession
  - Event-based architecture using AsyncStream

**Rendering Layer:**
- `ImageRendering` - CGImage and platform graphics utilities
- `RagnarokSprite` - Character sprite composition and rendering
  - ComposedSprite assembles sprites from body parts
  - SpriteRenderer renders animation sequences
- `RagnarokRenderers` - Metal-based 3D rendering
  - Metal shaders for Ground, Water, Model, Effect rendering
- `RagnarokReality` - RealityKit integration for visionOS
  - Converts Ragnarok 3D data to RealityKit entities

**Game Engine:**
- `RagnarokGame` - High-level game logic
  - GameSession state machine (Login → Char Select → Map Loading → Map Loaded)
  - MapScene for 3D map rendering, player movement, pathfinding, NPC dialogs
  - Event handling from network layer
- `WorldCamera` - 3D camera system
- `ThumbstickView` - UI controls

### Main Application Structure

**RagnarokOffline/** (main app target):
- `RagnarokOfflineApp.swift` - App entry point with platform-specific window management
- `AppModel.swift` - Central observable model managing:
  - Resource directories (local, iCloud synced, remote cached)
  - Server instances (Login, Char, Map, Web servers)
  - Database, Game Session, Chat Session, Character Simulator
- `Main/` - UI navigation structure (ContentView, SidebarView)
- `Core/` - Reusable UI components (MetalView, ModelViewer, ImageGrid)
- `GameClient/` - Game client UI and logic
- `Database/` - Database browsing UI
- `Server/` - Server management UI
- `ChatClient/` - Chat client interface
- `CharacterSimulator/` - Character preview tools
- `Settings/` - App configuration using @SettingsItem property wrapper

### swift-rathena Integration

The `swift-rathena` submodule wraps the C++ rAthena server in Swift Package Manager:

**Products (Dynamic Libraries):**
- `rAthenaCommon` - Core server utilities and database
- `rAthenaLogin` - Login server (account authentication)
- `rAthenaChar` - Character server (character management)
- `rAthenaMap` - Map server (gameplay logic)
- `rAthenaWeb` - Web API server
- `rAthenaResources` - Bundled configuration, databases, NPC scripts

The app runs these servers in-process on macOS/iOS for offline gameplay. The servers use:
- SQLite database (`ragnarok.sqlite3`) for accounts/characters
- YAML databases (`db/`) for game data (parsed by RagnarokDatabase)
- Lua/C scripts (`npc/`) for game logic

### Networking Architecture

**Client-Server Flow:**
```
GameSession
    ├─> LoginSession → Login Server
    │       └─> Events: loginAccepted, loginRefused
    │
    ├─> CharSession → Char Server
    │       └─> Events: charServerAccepted, makeCharacterAccepted
    │
    └─> MapSession → Map Server
            └─> Events: mapServerAccepted, mapChanged, playerMoved,
                       inventoryItemsAppended, mapObjectSpawned, npcDialogReceived
```

- Binary protocol based on rAthena packet definitions
- PacketRegistry maps packet type IDs to Swift structs
- PacketEncoder/Decoder handles serialization with BinaryIO
- AsyncStream for event delivery to UI layer

### Code Generation System

The `RagnarokOfflineGenerator` executable generates Swift code from C++ headers:

1. **generate-constants**: Parses C++ enums → Swift enums in RagnarokConstants/Generated/
   - JobID, SkillID, ItemType, MonsterMode, StatusChangeID, etc.
   - Uses SwiftSyntax for AST manipulation

2. **generate-packets**: Parses C++ packet structs → Swift structs in RagnarokPackets/Generated/
   - Creates packet registry with type mappings
   - Implements PacketProtocol conformance

Run `./generate.sh` whenever the C++ headers in swift-rathena change.

## Development Notes

### Build Configurations

The project uses Xcode configuration files (Configurations/*.xcconfig):
- `Development.xcconfig` - For local development
- `TestFlight.xcconfig` - For TestFlight builds
- `AppStore.xcconfig` - For App Store releases

Feature flags are controlled via `SWIFT_ACTIVE_COMPILATION_CONDITIONS`:
- `GAME_CLIENT_FEATURE` - Enables game client functionality
- `CHAT_CLIENT_FEATURE` - Enables chat client functionality

### Platform-Specific Behavior

The app adapts to each platform:
- **macOS**: WindowGroup with separate windows for main UI and game window
- **visionOS**: ImmersiveSpace for immersive game experience
- **iOS**: Standard UIKit integration

### Resource Management

Resources are loaded from multiple sources (priority order):
1. Local file system (user-provided data.grf)
2. GRF archives (compressed game assets)
3. Remote client (HTTP fallback when local resources unavailable)

The ResourceManager handles caching, fallback logic, and resource lookup tables.

### Database System

Game data comes from YAML files parsed by RagnarokDatabase:
- Supports both Renewal and Pre-Renewal modes
- Lazy loading with caching for performance
- Type-safe Swift models generated from YAML schemas

Server data stored in:
- SQLite database for accounts/characters
- YAML files for items, monsters, maps, skills, etc.

### Testing Strategy

The test plan includes tests for all packages:
- File format parsing (GRF, SPR, ACT, RSW, etc.)
- Network packet encoding/decoding
- Database parsing
- Rendering pipelines
- Binary I/O operations
- Math operations
- Sprite composition

Run tests via Xcode test plan or individual package `swift test`.

## Common Patterns

### Adding a New File Format Parser

1. Add parser to `RagnarokFileFormats`
2. Add tests to `RagnarokFileFormatsTests`
3. Update `ResourceManager` in `RagnarokResources` if needed
4. Add UI views in `RagnarokOffline/Database` if browsable

### Adding a New Network Packet

1. Define packet struct in `swift-rathena` C++ headers
2. Run `./generate.sh` to regenerate Swift packet definitions
3. Add packet handler in appropriate Session (LoginSession, CharSession, MapSession)
4. Update GameSession to respond to new events

### Adding a New Database Type

1. Define YAML schema in `swift-rathena/db/`
2. Add Swift model in `RagnarokDatabase`
3. Add parser for the new database type
4. Create UI browsing view in `RagnarokOffline/Database`
5. Update DatabaseModel to include new database

### Modifying C++ Server Code

1. Update code in `swift-rathena` submodule
2. If enums/packets changed, run `./generate.sh`
3. Update Swift code to handle new behavior
4. Test with embedded server in app
