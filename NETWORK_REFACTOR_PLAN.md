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

## Phase 3A: Refactor GameSession - Login Client

File: `Packages/RagnarokGame/Sources/RagnarokGame/GameSession.swift`

### 3A.1 Update Package.swift Dependencies
Add RagnarokPackets dependency to `Packages/RagnarokGame/Package.swift`:
```swift
dependencies: [
    .package(path: "../RagnarokNetwork"),
    .package(path: "../RagnarokPackets"),      // NEW
    .package(path: "../RagnarokModels"),
    // ... other dependencies
]
```

### 3A.2 Replace LoginSession with LoginClient
```swift
// Before
@ObservationIgnored var loginSession: LoginSession?

// After
@ObservationIgnored var loginClient: Client?
@ObservationIgnored var loginKeepaliveTask: Task<Void, Never>?
```

### 3A.3 Refactor startLoginSession() to startLoginClient()
Create new `startLoginClient()` method:
- Create Client instance for login server
- Handle errorStream and packetStream with separate Tasks
- Add 10-second keepalive timer sending `PACKET_CA_CONNECT_INFO_CHANGED`
- Call `connect()` on client

### 3A.4 Add Login Packet Handler
Replace `handleLoginEvent()` with `handleLoginPacket()`:
- Pattern match on packet types: `PACKET_ZC_ACCEPT_ENTER`, `PACKET_ZC_REFUSE_ENTER`, `PACKET_SC_NOTIFY_BAN`
- Convert packets to models using `Model(from: packet)`
- Update state directly (no events)

### 3A.5 Update login() Method
Send `PACKET_CA_LOGIN` directly via `loginClient.sendPacket()`

### 3A.6 Update selectCharServer() Method
Stop and disconnect loginClient before starting charSession

### 3A.7 Update stopAllSessions() Method
Cancel keepalive task and disconnect loginClient

**Packets Handled**: ~5 packet types (CA_LOGIN, CA_CONNECT_INFO_CHANGED, ZC_ACCEPT_ENTER, ZC_REFUSE_ENTER, SC_NOTIFY_BAN)

---

## Phase 3B: Refactor GameSession - Char Client

File: `Packages/RagnarokGame/Sources/RagnarokGame/GameSession.swift`

### 3B.1 Replace CharSession with CharClient
```swift
// Before
@ObservationIgnored var charSession: CharSession?

// After
@ObservationIgnored var charClient: Client?
@ObservationIgnored var charKeepaliveTask: Task<Void, Never>?
```

### 3B.2 Refactor startCharSession() to startCharClient()
Create new `startCharClient()` method:
- Create Client instance for char server
- Handle errorStream and packetStream with separate Tasks
- Add 12-second keepalive timer sending `PACKET_CH_ENTER`
- Send initial `PACKET_CH_ENTER` packet
- Call `connect()` on client

### 3B.3 Add Char Packet Handler
Replace `handleCharEvent()` with `handleCharPacket()`:
- Pattern match on packet types: `PACKET_ZC_ACCEPT_ENTER2`, `PACKET_ZC_NOTIFY_MAPINFO`, `PACKET_ZC_ACCEPT_MAKE_CHAR`, etc.
- Convert packets to models using `Model(from: packet)`
- Update state directly (no events)

### 3B.4 Add Character Operation Methods
Add methods for:
- `selectCharacter()` - Send `PACKET_CH_SELECT_CHAR`
- `createCharacter()` - Send `PACKET_CH_MAKE_CHAR`
- `deleteCharacter()` - Send `PACKET_CH_DELETE_CHAR`

### 3B.5 Update stopAllSessions() Method
Cancel keepalive task and disconnect charClient

### 3B.6 Stop CharClient When Transitioning to Map
Disconnect charClient before starting mapClient

**Packets Handled**: ~10 packet types (CH_ENTER, CH_SELECT_CHAR, CH_MAKE_CHAR, CH_DELETE_CHAR, ZC_ACCEPT_ENTER2, ZC_NOTIFY_MAPINFO, ZC_ACCEPT_MAKE_CHAR, etc.)

---

## Phase 3C: Refactor GameSession - Map Client

Files:
- `Packages/RagnarokGame/Sources/RagnarokGame/GameSession.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/MapScene.swift`

### 3C.1 Replace MapSession with MapClient
```swift
// Before
@ObservationIgnored var mapSession: MapSession?

// After
@ObservationIgnored var mapClient: Client?
@ObservationIgnored var currentMapServer: MapServerInfo?
```

### 3C.2 Refactor startMapSession() to startMapClient()
Create new `startMapClient()` method:
- Create Client instance for map server
- Handle errorStream and packetStream with separate Tasks
- No explicit keepalive timer (implicit via game packets)
- Send initial `PACKET_CZ_ENTER` packet
- Call `connect()` on client

### 3C.3 Add Map Packet Handler
Replace `handleMapEvent()` with `handleMapPacket()`:
- Pattern match on 30+ packet types for:
  - Connection & Map: `PACKET_ZC_ACCEPT_ENTER`, `PACKET_ZC_NPCACK_SERVERMOVE`, `PACKET_ZC_NPCACK_MAPMOVE`
  - Player: `PACKET_ZC_NOTIFY_PLAYERMOVE`, `PACKET_ZC_STATUS`, `PACKET_ZC_PAR_CHANGE`, `PACKET_ZC_ATTACK_RANGE`
  - Inventory: `PACKET_ZC_ITEM_ENTRY`, `PACKET_ZC_ITEM_FALL_ENTRY`, `PACKET_ZC_USE_ITEM_ACK`, `PACKET_ZC_EQUIP_ITEM_ACK`
  - Map Objects: `PACKET_ZC_NOTIFY_STANDENTRY`, `PACKET_ZC_NOTIFY_MOVE`, `PACKET_ZC_NOTIFY_VANISH`, `PACKET_ZC_NOTIFY_ACT`
  - NPC Dialogs: `PACKET_ZC_SAY_DIALOG`, `PACKET_ZC_WAIT_DIALOG`, `PACKET_ZC_MENU_LIST`, `PACKET_ZC_OPEN_EDITDLG`
  - Chat: `PACKET_ZC_NOTIFY_CHAT`
  - Achievements: `PACKET_ZC_ALL_ACH_LIST`, `PACKET_ZC_ACH_UPDATE`
- Convert packets to models using `Model(from: packet)`
- Update state directly (no events)

### 3C.4 Update MapScene Integration
Replace `mapSession` references with `mapClient` in MapScene:
- Update constructor to take `Client` instead of `MapSession`
- Replace all `mapSession.sendPacket()` calls with `mapClient.sendPacket()`

### 3C.5 Update NPC Interaction Methods
Update GameSession methods to use mapClient:
- `requestNextMessage()` - Send `PACKET_CZ_REQ_NEXT_SCRIPT`
- `closeDialog()` - Send `PACKET_CZ_CLOSE_DIALOG`
- `selectMenu()` - Send `PACKET_CZ_CHOOSE_MENU`
- `confirmInput()` - Send `PACKET_CZ_INPUT_EDITDLG` or `PACKET_CZ_INPUT_EDITDLGSTR`

### 3C.6 Update stopAllSessions() Method
Disconnect mapClient

**Packets Handled**: 30+ packet types covering all gameplay aspects (movement, inventory, NPCs, objects, status, dialogs, chat, achievements)

---

## Phase 3 Summary

Phase 3 is split into three sub-phases:
- **3A (Login)**: Simplest - 5 packets, 10s keepalive, basic authentication
- **3B (Char)**: Moderate - 10 packets, 12s keepalive, character management
- **3C (Map)**: Most complex - 30+ packets, no keepalive, full gameplay

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
- `/Packages/RagnarokGame/Sources/RagnarokGame/GameSession.swift` - Major refactor (Phase 3A, 3B, 3C)
- `/Packages/RagnarokGame/Sources/RagnarokGame/MapScene.swift` - Update to use Client (Phase 3C)
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
4. **Phase 3A**: Refactor GameSession - Login Client
5. **Phase 3B**: Refactor GameSession - Char Client
6. **Phase 3C**: Refactor GameSession - Map Client
7. **Phase 4**: Refactor ChatSession to use Client directly
8. **Phase 5**: Delete Sessions, Events, subscription infrastructure, old Models
9. **Phase 6**: Clean up package dependencies
10. **Testing**: Verify game client and chat client work correctly
