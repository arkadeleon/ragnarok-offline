# RagnarokNetwork Module Refactor Plan

## Goal
Simplify RagnarokNetwork to only handle raw packet send/receive, moving event handling and model conversion to consumers (Game/Chat clients) and a new RagnarokModels package.

## Architecture Changes

### Before
```
RagnarokNetwork (package)
├── RagnarokNetwork (target)
│   ├── Client (internal)
│   ├── Sessions (LoginSession, CharSession, MapSession)
│   │   └── Events (nested enums)
│   ├── Models (21 files)
│   └── Events (14 unused protocol files)
└── RagnarokPackets (target)
```

### After
```
RagnarokPackets (standalone package)
└── Packet definitions

RagnarokModels (new package)
├── Models (21 files)
└── Converters (packet → model inits)
    └── depends on: RagnarokPackets, RagnarokConstants

RagnarokNetwork (package)
└── Client (public)
    └── depends on: RagnarokPackets
```

---

## Phase 0: Extract RagnarokPackets to Standalone Package

### 0.1 Create new package structure
Create `/Packages/RagnarokPackets/`:
```
RagnarokPackets/
├── Package.swift
└── Sources/RagnarokPackets/
    └── (move all files from RagnarokNetwork/Sources/RagnarokPackets/)
```

### 0.2 Create Package.swift for RagnarokPackets
```swift
dependencies: [
    .package(path: "../BinaryIO"),
]
```

### 0.3 Update RagnarokNetwork Package.swift
- Remove RagnarokPackets target
- Add dependency on new RagnarokPackets package
- Re-export RagnarokPackets if needed for compatibility

### 0.4 Update generate.sh
Update the packet generation output path:
```bash
# Before
swift run ragnarok-offline-generator generate-packets ../swift-rathena ../Packages/RagnarokNetwork/Sources/RagnarokPackets/Generated

# After
swift run ragnarok-offline-generator generate-packets ../swift-rathena ../Packages/RagnarokPackets/Sources/RagnarokPackets/Generated
```

### 0.5 Update all consumers
Update packages that depend on RagnarokPackets via RagnarokNetwork to depend on RagnarokPackets directly.

---

## Phase 1: Create RagnarokModels Package

### 1.1 Create package structure
Create `/Packages/RagnarokModels/`:
```
RagnarokModels/
├── Package.swift
└── Sources/RagnarokModels/
    └── (model files)
```

### 1.2 Move model files
Move from `Packages/RagnarokNetwork/Sources/RagnarokNetwork/Models/` to `Packages/RagnarokModels/Sources/RagnarokModels/`:

| File | Notes |
|------|-------|
| `AccountInfo.swift` | Keep packet init |
| `BannedMessage.swift` | Keep packet init |
| `CharServerInfo.swift` | Keep packet init |
| `CharacterBasicStatus.swift` | Keep packet init |
| `CharacterInfo.swift` | Keep packet init |
| `ChatMessage.swift` | Keep packet init |
| `EquippedItem.swift` | Keep packet init |
| `InventoryItem.swift` | Keep packet init |
| `LoginRefusedMessage.swift` | Keep packet init |
| `MapItem.swift` | Keep packet init |
| `MapObject.swift` | Keep packet inits |
| `MapObjectAction.swift` | Keep packet init |
| `MapServerInfo.swift` | Keep packet init |
| `MoveData.swift` | Keep data init |
| `NPCDialog.swift` | Pure model (no packet init) |
| `PickedUpItem.swift` | Keep packet init |
| `PosDir.swift` | Keep data init |
| `ThrownItem.swift` | Keep packet init |
| `UnequippedItem.swift` | Keep packet init |
| `UsedItem.swift` | Keep packet init |
| `AccessibleMapInfo.swift` | Keep packet init |

### 1.3 Create Package.swift for RagnarokModels
```swift
dependencies: [
    .package(path: "../RagnarokPackets"),
    .package(path: "../RagnarokConstants"),
]
```

### 1.4 Update model initializers
Change internal packet inits to public inits with `from:` label:
```swift
// Before (internal)
init(packet: packet_spawn_unit) { ... }

// After (public)
public init(from packet: packet_spawn_unit) { ... }
```

---

## Phase 2: Refactor RagnarokNetwork Client

### 2.1 Make Client public
File: `Packages/RagnarokNetwork/Sources/RagnarokNetwork/Client/Client.swift`

- Change `final class Client` → `public final class Client`
- Make `packetStream` and `errorStream` public
- Remove `ClientSubscription` parameter from `connect()`
- Simplify to just connection management + packet streams

### 2.2 New Client public API
```swift
public final class Client: Sendable {
    public let errorStream: AsyncStream<ClientError>
    public let packetStream: AsyncStream<any DecodablePacket>

    public init(name: String, address: String, port: UInt16)
    public func connect()
    public func disconnect()
    public func sendPacket(_ packet: some EncodablePacket)  // Silent failure if disconnected
}

public enum ClientError: Error, Sendable { ... }
```

---

## Phase 3: Refactor GameSession

File: `Packages/RagnarokGame/Sources/RagnarokGame/GameSession.swift`

### 3.1 Replace Sessions with direct Client usage
```swift
// Before
var loginSession: LoginSession?
var charSession: CharSession?
var mapSession: MapSession?

// After
var loginClient: Client?
var charClient: Client?
var mapClient: Client?
```

### 3.2 Add packet handling
Move packet subscription logic from Sessions to GameSession:
- Handle packets via pattern matching: `case let packet as PACKET_ZC_*`
- Convert packets to models using `Model(from: packet)`
- Update state directly (no events)

### 3.3 Add keepAlive timers
Each client maintains its own timer Task:
- Login: 10s ping with `PACKET_CA_CONNECT_INFO_CHANGED`
- Char: 12s ping with `PACKET_CH_ENTER`
- Map: (implicit via packets)

### 3.4 Update Package.swift dependencies
```swift
dependencies: [
    .package(path: "../RagnarokNetwork"),
    .package(path: "../RagnarokPackets"),
    .package(path: "../RagnarokModels"),
]
```

---

## Phase 4: Refactor ChatSession

File: `RagnarokOffline/ChatClient/ChatSession.swift`

Apply same changes as GameSession:
- Replace Session usage with direct Client
- Add packet handling with pattern matching
- Add keepAlive timer Tasks (owned by ChatSession)
- Convert packets to models with RagnarokModels

---

## Phase 5: Remove Sessions, Events, and Subscription Infrastructure from RagnarokNetwork

### 5.1 Delete Session files
Delete entire folder: `Packages/RagnarokNetwork/Sources/RagnarokNetwork/Sessions/`
- `SessionProtocol.swift`
- `LoginSession.swift`
- `CharSession.swift`
- `MapSession.swift`
- `MapSession+Player.swift`
- `MapSession+NPC.swift`
- `MapSession+Item.swift`
- `MapSession+Mail.swift`

### 5.2 Delete subscription infrastructure
Delete files (no longer used after Phase 3-4):
- `Packages/RagnarokNetwork/Sources/RagnarokNetwork/Client/ClientSubscription.swift`
- `Packages/RagnarokNetwork/Sources/RagnarokNetwork/Client/PacketHandler.swift`

### 5.3 Delete Events folder
Delete entire folder: `Packages/RagnarokNetwork/Sources/RagnarokNetwork/Events/` (14 unused files)

### 5.4 Delete old Models folder
Delete entire folder: `Packages/RagnarokNetwork/Sources/RagnarokNetwork/Models/` (moved to RagnarokModels in Phase 1)

### 5.5 Update RagnarokNetwork Package.swift
- Remove `RagnarokConstants` dependency (now only needed by RagnarokModels)
- Keep only `RagnarokPackets` and `BinaryIO` dependencies

---

## Phase 6: Update Package Dependencies

### RagnarokPackets/Package.swift (new standalone)
```swift
dependencies: [
    .package(path: "../BinaryIO"),
]
```

### RagnarokNetwork/Package.swift
```swift
dependencies: [
    .package(path: "../BinaryIO"),
    .package(path: "../RagnarokPackets"),
    // RagnarokConstants removed
]
```

### RagnarokModels/Package.swift (new)
```swift
dependencies: [
    .package(path: "../RagnarokPackets"),
    .package(path: "../RagnarokConstants"),
]
```

### RagnarokGame/Package.swift
```swift
dependencies: [
    .package(path: "../RagnarokNetwork"),
    .package(path: "../RagnarokPackets"),
    .package(path: "../RagnarokModels"),
]
```

---

## Critical Files Summary

### Files to Create
- `/Packages/RagnarokPackets/Package.swift` (standalone package)
- `/Packages/RagnarokPackets/Sources/RagnarokPackets/*.swift` (moved from RagnarokNetwork)
- `/Packages/RagnarokModels/Package.swift`
- `/Packages/RagnarokModels/Sources/RagnarokModels/*.swift` (21 model files)

### Files to Modify
- `/Packages/RagnarokNetwork/Package.swift` - Remove RagnarokPackets target, add dependency
- `/Packages/RagnarokNetwork/Sources/RagnarokNetwork/Client/Client.swift` - Make public, simplify API
- `/Packages/RagnarokGame/Sources/RagnarokGame/GameSession.swift` - Major refactor
- `/Packages/RagnarokGame/Package.swift` - Add RagnarokModels, RagnarokPackets dependencies
- `/RagnarokOffline/ChatClient/ChatSession.swift` - Major refactor

### Files to Delete
- `/Packages/RagnarokNetwork/Sources/RagnarokPackets/` (after move to standalone package)
- `/Packages/RagnarokNetwork/Sources/RagnarokNetwork/Client/ClientSubscription.swift`
- `/Packages/RagnarokNetwork/Sources/RagnarokNetwork/Client/PacketHandler.swift`
- `/Packages/RagnarokNetwork/Sources/RagnarokNetwork/Sessions/` (8 files)
- `/Packages/RagnarokNetwork/Sources/RagnarokNetwork/Events/` (14 files)
- `/Packages/RagnarokNetwork/Sources/RagnarokNetwork/Models/` (21 files)

---

## Execution Order

1. **Phase 0**: Extract RagnarokPackets to standalone package
2. **Phase 1**: Create RagnarokModels package and move models
3. **Phase 2**: Refactor Client to be public (Sessions still work temporarily)
4. **Phase 3**: Refactor GameSession to use Client directly
5. **Phase 4**: Refactor ChatSession to use Client directly
6. **Phase 5**: Delete Sessions, Events, subscription infrastructure, old Models
7. **Phase 6**: Clean up package dependencies
8. **Testing**: Verify game client and chat client work correctly
