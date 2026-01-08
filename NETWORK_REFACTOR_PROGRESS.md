# Network Refactor Progress

## Phase 0: Extract RagnarokPackets to Standalone Package

**Status**: ✅ COMPLETED & VERIFIED

**Date Completed**: 2026-01-07

### What Was Done

#### 1. Created New Package Structure
- Created `/Packages/RagnarokPackets/` with proper SPM directory structure
- Created `Sources/RagnarokPackets/` directory
- Created `Tests/RagnarokPacketsTests/` directory

#### 2. Moved Source Files
- Moved all 98 source files from `Packages/RagnarokNetwork/Sources/RagnarokPackets/` to `Packages/RagnarokPackets/Sources/RagnarokPackets/`
- Preserved subdirectory structure:
  - `Generated/` (2 files: packets.swift, packetdb.swift)
  - `Packets/` (28 packet definition files)
  - `Deprecated/` (60 deprecated files)
  - 8 core framework files (PacketProtocol.swift, PacketDecoder.swift, PacketEncoder.swift, etc.)

#### 3. Moved Test Files
- Moved 2 test files from `Packages/RagnarokNetwork/Tests/RagnarokPacketsTests/` to `Packages/RagnarokPackets/Tests/RagnarokPacketsTests/`
  - `PacketDatabaseTests.swift`
  - `PacketRegistryTests.swift`

#### 4. Created Package.swift
- Created new `Packages/RagnarokPackets/Package.swift` with:
  - Swift tools version 6.0
  - Platforms: macOS 13+, iOS 16+
  - Single dependency: BinaryIO
  - RagnarokPackets library product
  - RagnarokPackets target
  - RagnarokPacketsTests test target

#### 5. Updated RagnarokNetwork Package.swift
- Removed RagnarokPackets product from products array
- Added dependency on external RagnarokPackets package: `.package(path: "../RagnarokPackets")`
- Removed RagnarokPackets target from targets array
- Removed RagnarokPacketsTests test target
- RagnarokNetwork target now references external RagnarokPackets dependency

#### 6. Cleaned Up Old Directories
- Deleted `Packages/RagnarokNetwork/Sources/RagnarokPackets/` (after successful move)
- Deleted `Packages/RagnarokNetwork/Tests/RagnarokPacketsTests/` (after successful move)

#### 7. Updated Code Generation Script
- Updated `generate.sh` line 5 to output packets to new location:
  - Old: `../Packages/RagnarokNetwork/Sources/RagnarokPackets/Generated`
  - New: `../Packages/RagnarokPackets/Sources/RagnarokPackets/Generated`

### Files Modified

| File | Type | Description |
|------|------|-------------|
| `Packages/RagnarokPackets/Package.swift` | Created | New standalone package manifest |
| `Packages/RagnarokNetwork/Package.swift` | Modified | Removed internal target, added external dependency |
| `generate.sh` | Modified | Updated packet generation output path |

### Directories Created

- `/Packages/RagnarokPackets/`
- `/Packages/RagnarokPackets/Sources/RagnarokPackets/`
- `/Packages/RagnarokPackets/Tests/RagnarokPacketsTests/`

### Directories Deleted

- `/Packages/RagnarokNetwork/Sources/RagnarokPackets/`
- `/Packages/RagnarokNetwork/Tests/RagnarokPacketsTests/`

### What Should Work Now

1. RagnarokPackets is now a standalone package that can be used independently
2. RagnarokNetwork imports RagnarokPackets as an external dependency
3. No changes to consuming code needed - all imports continue to work
4. Code generation with `./generate.sh` outputs to the correct new location
5. All existing tests should pass without modification

### Testing Checklist for User

- [ ] Build succeeds: `swift build` in root directory
- [ ] All tests pass: Run tests in Xcode or via `swift test`
- [ ] RagnarokPackets package builds independently: `cd Packages/RagnarokPackets && swift build`
- [ ] RagnarokPackets tests pass independently: `cd Packages/RagnarokPackets && swift test`
- [ ] Code generation works: `./generate.sh` runs without errors
- [ ] Main application builds and runs in Xcode
- [ ] No import errors in any consuming code

---

## Phase 1: Create RagnarokModels Package

**Status**: ✅ COMPLETED & VERIFIED

**Date Completed**: 2026-01-07

### What Was Done

#### 1. Created New Package Structure
- Created `/Packages/RagnarokModels/` with proper SPM directory structure
- Created `Sources/RagnarokModels/` directory
- Created `Tests/RagnarokModelsTests/` directory

#### 2. Created Package.swift for RagnarokModels
- Created new `Packages/RagnarokModels/Package.swift` with:
  - Swift tools version 6.0
  - Platforms: macOS 13+, iOS 16+
  - Dependencies: RagnarokPackets, RagnarokConstants
  - RagnarokModels library product
  - RagnarokModels target
  - RagnarokModelsTests test target

#### 3. Moved Model Files
Moved all 21 model files from `Packages/RagnarokNetwork/Sources/RagnarokNetwork/Models/` to `Packages/RagnarokModels/Sources/RagnarokModels/`:

| File | Notes |
|------|-------|
| `AccountInfo.swift` | Updated packet init to public |
| `BannedMessage.swift` | Updated packet init to public |
| `CharServerInfo.swift` | Updated packet init to public |
| `CharacterBasicStatus.swift` | Updated packet init to public |
| `CharacterInfo.swift` | Already had public inits |
| `ChatMessage.swift` | Updated init to public |
| `EquippedItem.swift` | Updated packet init to public |
| `InventoryItem.swift` | Updated packet inits to public |
| `LoginRefusedMessage.swift` | Updated packet init to public |
| `MapItem.swift` | Updated packet inits to public |
| `MapObject.swift` | Updated packet inits to public |
| `MapObjectAction.swift` | Updated packet init to public |
| `MapServerInfo.swift` | Updated packet init to public |
| `MoveData.swift` | Made struct public, updated data init to public |
| `NPCDialog.swift` | Pure model (no packet init) |
| `PickedUpItem.swift` | Updated packet init to public |
| `PosDir.swift` | Made struct public, updated data init to public |
| `ThrownItem.swift` | Updated packet init to public |
| `UnequippedItem.swift` | Updated packet init to public |
| `UsedItem.swift` | Updated packet init to public |
| `AccessibleMapInfo.swift` | Updated packet init to public |

#### 4. Updated Model Initializers
- Changed all internal `init(packet:)` to `public init(from packet:)`
- Changed all internal `init(data:)` to `public init(from data:)` for `MoveData` and `PosDir`
- Changed `init(sub:)` to `public init(from sub:)` for `CharServerInfo`
- Changed `init(map:)` to `public init(from map:)` for `AccessibleMapInfo`
- Changed `init(item:)` to `public init(from item:)` for `InventoryItem`
- Made `MoveData` and `PosDir` structs public
- Made their computed properties public

#### 5. Updated RagnarokNetwork Package
- Added `RagnarokModels` dependency to `Package.swift`
- Updated dependency order to: BinaryIO, RagnarokConstants, RagnarokModels, RagnarokPackets
- Added `import RagnarokModels` to Session files:
  - `LoginSession.swift`
  - `CharSession.swift`
  - `MapSession.swift`
  - `MapSession+Item.swift`

#### 6. Updated Model Initializer Calls
Updated all model initializer calls in Session files to use `from:` label:
- `AccountInfo(from: packet)` in LoginSession.swift:51
- `CharServerInfo(from: $0)` in LoginSession.swift:52
- `LoginRefusedMessage(from: packet)` in LoginSession.swift:61
- `BannedMessage(from: packet)` in LoginSession.swift:68, CharSession.swift:80, MapSession.swift:155
- `MapServerInfo(from: packet)` in CharSession.swift:118
- `CharacterInfo(from: packet.character)` in CharSession.swift:135
- `AccessibleMapInfo(from: $0)` in CharSession.swift:126
- `MapObject(from: packet)` in MapSession.swift:251, 267, 283
- `PosDir(from: packet.PosDir)` in MapSession.swift:252, 268
- `MoveData(from: packet.MoveData)` in MapSession.swift:284
- `MapObjectAction(from: packet)` in MapSession.swift:341
- `InventoryItem(from: $0)` in MapSession+Item.swift:28, 35
- `MapItem(from: packet)` in MapSession+Item.swift:42, 51
- `PickedUpItem(from: packet)` in MapSession+Item.swift:66
- `ThrownItem(from: packet)` in MapSession+Item.swift:73
- `UsedItem(from: packet)` in MapSession+Item.swift:80
- `EquippedItem(from: packet)` in MapSession+Item.swift:91
- `UnequippedItem(from: packet)` in MapSession+Item.swift:101

#### 7. Cleaned Up Old Directories
- Deleted `Packages/RagnarokNetwork/Sources/RagnarokNetwork/Models/` (after successful move)

### Files Created

| File | Type | Description |
|------|------|-------------|
| `Packages/RagnarokModels/Package.swift` | Created | New standalone package manifest |
| `Packages/RagnarokModels/Sources/RagnarokModels/*.swift` | Created | 21 model files moved from RagnarokNetwork |

### Files Modified

| File | Type | Description |
|------|------|-------------|
| `Packages/RagnarokNetwork/Package.swift` | Modified | Added RagnarokModels dependency |
| `Packages/RagnarokNetwork/Sources/RagnarokNetwork/Sessions/LoginSession.swift` | Modified | Added import, updated initializer calls |
| `Packages/RagnarokNetwork/Sources/RagnarokNetwork/Sessions/CharSession.swift` | Modified | Added import, updated initializer calls |
| `Packages/RagnarokNetwork/Sources/RagnarokNetwork/Sessions/MapSession.swift` | Modified | Added import, updated initializer calls |
| `Packages/RagnarokNetwork/Sources/RagnarokNetwork/Sessions/MapSession+Item.swift` | Modified | Added import, updated initializer calls |

### Directories Created

- `/Packages/RagnarokModels/`
- `/Packages/RagnarokModels/Sources/RagnarokModels/`
- `/Packages/RagnarokModels/Tests/RagnarokModelsTests/`

### Directories Deleted

- `/Packages/RagnarokNetwork/Sources/RagnarokNetwork/Models/`

### What Should Work Now

1. RagnarokModels is now a standalone package that can be used independently
2. RagnarokModels depends on RagnarokPackets and RagnarokConstants
3. RagnarokNetwork imports RagnarokModels as an external dependency
4. All model initializers use the `from:` label for clarity
5. All Session code continues to work with updated initializer calls
6. All existing tests pass without modification

---

## Phase 2: Refactor RagnarokNetwork Client

**Status**: ✅ COMPLETED & VERIFIED

**Date Completed**: 2026-01-07

### What Was Done

#### 1. Made Client Public
- Changed `enum ClientError` to `public enum ClientError: Error, Sendable`
- Changed `final class Client` to `public final class Client`
- Made `errorStream: AsyncStream<ClientError>` public
- Made `packetStream: AsyncStream<any DecodablePacket>` public
- Made all methods public: `init()`, `connect()`, `disconnect()`, `sendPacket()`

#### 2. Simplified connect() Method
- Removed `ClientSubscription` parameter from `connect(with:)`
- Changed signature from `func connect(with subscription: ClientSubscription)` to `public func connect()`
- Removed internal Task creation for error and packet stream handling
- Simplified to only handle connection establishment and state management
- Consumers now iterate over `errorStream` and `packetStream` directly

#### 3. Updated Session Files for Compatibility
Updated all three Session files to maintain backward compatibility during transition:

**LoginSession.swift**:
- Changed `client.connect(with: subscription)` to `client.connect()`
- Added manual Task creation to iterate over `client.errorStream`
- Added manual Task creation to iterate over `client.packetStream`
- Applied subscription handlers to incoming errors and packets

**CharSession.swift**:
- Changed `client.connect(with: subscription)` to `client.connect()`
- Added manual Task creation to iterate over `client.errorStream`
- Added manual Task creation to iterate over `client.packetStream`
- Applied subscription handlers to incoming errors and packets

**MapSession.swift**:
- Changed `client.connect(with: subscription)` to `client.connect()`
- Added manual Task creation to iterate over `client.errorStream`
- Added manual Task creation to iterate over `client.packetStream`
- Applied subscription handlers to incoming errors and packets

### New Public Client API

```swift
public final class Client: Sendable {
    public let errorStream: AsyncStream<ClientError>
    public let packetStream: AsyncStream<any DecodablePacket>

    public init(name: String, address: String, port: UInt16)
    public func connect()
    public func disconnect()
    public func sendPacket(_ packet: some EncodablePacket)
}

public enum ClientError: Error, Sendable {
    case decoding(any Error)
    case encoding(any Error)
    case network(NWError)
}
```

### Files Modified

| File | Type | Description |
|------|------|-------------|
| `Packages/RagnarokNetwork/Sources/RagnarokNetwork/Client/Client.swift` | Modified | Made class and API public, simplified connect() |
| `Packages/RagnarokNetwork/Sources/RagnarokNetwork/Sessions/LoginSession.swift` | Modified | Updated to use new Client API |
| `Packages/RagnarokNetwork/Sources/RagnarokNetwork/Sessions/CharSession.swift` | Modified | Updated to use new Client API |
| `Packages/RagnarokNetwork/Sources/RagnarokNetwork/Sessions/MapSession.swift` | Modified | Updated to use new Client API |

### What Should Work Now

1. Client is now public and can be used directly by consumers outside RagnarokNetwork
2. Client has a simplified connect() API that doesn't require subscription infrastructure
3. Consumers can directly iterate over errorStream and packetStream for async packet handling
4. All existing Sessions continue to work with the new Client API
5. Sessions maintain their event-based architecture temporarily during transition
6. All tests pass without modification

---

## Phase 3A: Refactor GameSession - Login Client

**Status**: ✅ COMPLETED & VERIFIED

**Date Completed**: 2026-01-08

### What Was Done

#### 1. Updated Package.swift Dependencies

Added RagnarokPackets and RagnarokModels dependencies to `Packages/RagnarokGame/Package.swift`:
- Added `.package(path: "../RagnarokModels")` to dependencies array
- Added `.package(path: "../RagnarokPackets")` to dependencies array
- Added `"RagnarokModels"` to RagnarokGame target dependencies
- Added `"RagnarokPackets"` to RagnarokGame target dependencies

#### 2. Replaced LoginSession with LoginClient

In `Packages/RagnarokGame/Sources/RagnarokGame/GameSession.swift`:
- Removed `@ObservationIgnored var loginSession: LoginSession?`
- Added `@ObservationIgnored var loginClient: Client?`
- Added `@ObservationIgnored var loginKeepaliveTask: Task<Void, Never>?`
- Added `private var username: String?` to store username for keepalive packets
- Added `import RagnarokPackets` to imports

#### 3. Refactored startLoginSession() to startLoginClient()

Replaced `startLoginSession()` with `startLoginClient()`:
- Creates `Client` instance with login server address and port
- Spawns Task to handle `client.errorStream` - converts errors to ErrorMessage and appends to errorMessages
- Spawns Task to handle `client.packetStream` - calls `handleLoginPacket()` for each packet
- Calls `client.connect()` to establish connection
- Stores client in `self.loginClient`

#### 4. Added handleLoginPacket() Method

Created new `handleLoginPacket(_ packet: any DecodablePacket)` method:
- Pattern matches on packet types using `switch` and `case let packet as PacketType:`
- Handles `PACKET_AC_ACCEPT_LOGIN`:
  - Converts packet to `AccountInfo(from: packet)`
  - Maps char_servers to `CharServerInfo(from:)`
  - Stores account
  - Auto-selects char server if only 1, or shows char server list if multiple
  - Calls `startLoginKeepalive()` to begin keepalive timer
- Handles `PACKET_AC_REFUSE_LOGIN`:
  - Converts packet to `LoginRefusedMessage(from: packet)`
  - Looks up localized message from messageStringTable
  - Appends error message to errorMessages
- Handles `PACKET_SC_NOTIFY_BAN`:
  - Converts packet to `BannedMessage(from: packet)`
  - Looks up localized message from messageStringTable
  - Appends error message to errorMessages

#### 5. Added startLoginKeepalive() Method

Created new `startLoginKeepalive()` method:
- Spawns Task that loops indefinitely
- Sleeps for 10 seconds using `try? await Task.sleep(for: .seconds(10))`
- Checks for cancellation with `guard !Task.isCancelled`
- Sends `PACKET_CA_CONNECT_INFO_CHANGED` with stored username
- Stores task in `self.loginKeepaliveTask`

#### 6. Updated login() Method

Refactored `login(username: String, password: String)`:
- Stores username in `self.username` for keepalive packets
- Calls `startLoginClient()` instead of `startLoginSession()`
- Creates `PACKET_CA_LOGIN` packet directly
- Sets packet fields: packetType, version, username, password, clienttype
- Sends packet via `loginClient?.sendPacket(packet)`
- Calls `loginClient?.receivePacket()` to trigger packet reception

#### 7. Updated selectCharServer() Method

Modified `selectCharServer(_ charServer: CharServerInfo)`:
- Cancels `loginKeepaliveTask` before transitioning to char server
- Sets `loginKeepaliveTask` to nil
- Disconnects `loginClient`
- Sets `loginClient` to nil
- Then calls `startCharSession(charServer)`

#### 8. Updated stopAllSessions() Method

Modified `stopAllSessions()`:
- Cancels `loginKeepaliveTask`
- Sets `loginKeepaliveTask` to nil
- Disconnects `loginClient`
- Sets `loginClient` to nil
- Continues to stop charSession and mapSession as before

### Files Modified

| File | Type | Description |
|------|------|-------------|
| `Packages/RagnarokGame/Package.swift` | Modified | Added RagnarokModels and RagnarokPackets dependencies |
| `Packages/RagnarokGame/Sources/RagnarokGame/GameSession.swift` | Modified | Complete refactor of login flow from LoginSession to Client |

### Packets Handled

Phase 3A handles 5 packet types:
- `PACKET_CA_LOGIN` (sent) - Login authentication request
- `PACKET_CA_CONNECT_INFO_CHANGED` (sent) - Keepalive packet every 10 seconds
- `PACKET_AC_ACCEPT_LOGIN` (received) - Successful login response
- `PACKET_AC_REFUSE_LOGIN` (received) - Login refused response
- `PACKET_SC_NOTIFY_BAN` (received) - Account banned notification

### What Should Work Now

1. GameSession no longer depends on LoginSession
2. Login flow uses Client directly with async packet streams
3. No event-based architecture for login - direct packet handling
4. Keepalive timer managed by GameSession using Task
5. All login functionality works identically to before
6. Tests pass without modification

### Testing Checklist

- [x] Build succeeds: `swift build` in RagnarokGame package
- [x] All tests pass
- [x] Login client connects and authenticates
- [x] Keepalive packets sent every 10 seconds
- [x] Login errors handled correctly
- [x] Transition to char server disconnects login client properly

---

## Phase 3B: Refactor GameSession - Char Client

**Status**: ✅ COMPLETED & VERIFIED

**Date Completed**: 2026-01-08

### What Was Done

#### 1. Replaced CharSession with CharClient

In `Packages/RagnarokGame/Sources/RagnarokGame/GameSession.swift`:
- Removed `@ObservationIgnored var charSession: CharSession?`
- Added `@ObservationIgnored var charClient: Client?`
- Added `@ObservationIgnored var charKeepaliveTask: Task<Void, Never>?`

#### 2. Refactored startCharSession() to startCharClient()

Replaced `startCharSession()` with `startCharClient()`:
- Creates `Client` instance with char server address and port
- Spawns Task to handle `client.errorStream` - converts errors to ErrorMessage and appends to errorMessages
- Spawns Task to handle `client.packetStream` - calls `handleCharPacket()` for each packet
- Calls `client.connect()` to establish connection
- Sends initial `PACKET_CH_ENTER` packet with account credentials
- Receives accountID (4 bytes) and updates account
- Calls `startCharKeepalive()` to begin keepalive timer
- Stores client in `self.charClient`

#### 3. Added handleCharPacket() Method

Created new `handleCharPacket(_ packet: any DecodablePacket)` method:
- Pattern matches on packet types using `switch` and `case let packet as PacketType:`
- Handles char server connection packets:
  - `PACKET_HC_ACCEPT_ENTER`: Converts to character list, updates state to characterSelect phase
  - `PACKET_HC_REFUSE_ENTER`: Appends error message for refused connection
  - `PACKET_HC_NOTIFY_ZONESVR`: Extracts map server info, stops charClient, starts mapSession
  - `PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME`: Accessible maps notification (currently unused)
- Handles character operation packets:
  - `PACKET_HC_ACCEPT_MAKECHAR`: Converts to CharacterInfo, appends to characters, updates phase
  - `PACKET_HC_REFUSE_MAKECHAR`: Appends error message
  - `PACKET_HC_ACCEPT_DELETECHAR`: Character deleted successfully
  - `PACKET_HC_REFUSE_DELETECHAR`: Appends error message
  - `PACKET_HC_DELETE_CHAR3`: Checks result field for success/failure
  - `PACKET_HC_DELETE_CHAR3_CANCEL`: Character deletion cancelled
  - `PACKET_HC_DELETE_CHAR3_RESERVED`: Character deletion reserved
- Handles other packets:
  - `PACKET_HC_ACCEPT_ENTER2`: Additional enter response
  - `PACKET_HC_SECOND_PASSWD_LOGIN`: Second password login
  - `PACKET_HC_CHARLIST_NOTIFY`: Character list notification
  - `PACKET_HC_BLOCK_CHARACTER`: Character block notification
  - `PACKET_SC_NOTIFY_BAN`: Account banned notification with localized message
- Stops charClient (keepalive task + disconnect) before transitioning to map server

#### 4. Added startCharKeepalive() Method

Created new `startCharKeepalive()` method:
- Spawns Task that loops indefinitely
- Sleeps for 12 seconds using `try? await Task.sleep(for: .seconds(12))`
- Checks for cancellation with `guard !Task.isCancelled`
- Sends `PACKET_PING` with account ID
- Stores task in `self.charKeepaliveTask`

#### 5. Added Character Operation Methods

Created three new public methods in GameSession:

**selectCharacter(slot: Int)**:
- Sends `PACKET_CH_SELECT_CHAR` with slot number
- Triggers server to send `PACKET_HC_NOTIFY_ZONESVR` with map server info

**createCharacter(_ character: CharacterInfo)**:
- Sends `PACKET_CH_MAKE_CHAR` with character details (name, slot, hair, stats, job, sex)
- Triggers server to send `PACKET_HC_ACCEPT_MAKECHAR` or `PACKET_HC_REFUSE_MAKECHAR`

**deleteCharacter(charID: UInt32)**:
- Sends `PACKET_CH_DELETE_CHAR3` with character ID
- Triggers server to send `PACKET_HC_DELETE_CHAR3` with result

#### 6. Updated selectCharServer() Method

Modified `selectCharServer(_ charServer: CharServerInfo)`:
- Cancels `loginKeepaliveTask` before transitioning to char server
- Sets `loginKeepaliveTask` to nil
- Disconnects `loginClient`
- Sets `loginClient` to nil
- Calls `startCharClient(charServer)` instead of `startCharSession(charServer)`

#### 7. Updated stopAllSessions() Method

Modified `stopAllSessions()`:
- Cancels `charKeepaliveTask` and sets to nil
- Disconnects `charClient` and sets to nil
- Continues to handle mapSession, loginKeepaliveTask, loginClient as before

#### 8. Updated startMapSession() Method

Modified `startMapSession(character:mapServer:)`:
- Changed from `guard let account = charSession?.account` to `guard let account`
- Uses GameSession's `account` property directly instead of accessing via charSession

#### 9. Updated UI View Files

**CharacterMakeView.swift**:
- Changed from `gameSession.charSession?.makeCharacter(character: character)`
- To: `gameSession.createCharacter(character)`

**CharacterSelectView.swift**:
- Changed from `gameSession.charSession?.selectCharacter(slot: selectedCharacter.charNum)`
- To: `gameSession.selectCharacter(slot: selectedCharacter.charNum)`

### Files Modified

| File | Type | Description |
|------|------|-------------|
| `Packages/RagnarokGame/Sources/RagnarokGame/GameSession.swift` | Modified | Complete refactor of char flow from CharSession to Client |
| `Packages/RagnarokGame/Sources/RagnarokGame/Views/CharacterMakeView.swift` | Modified | Updated to call new GameSession.createCharacter() method |
| `Packages/RagnarokGame/Sources/RagnarokGame/Views/CharacterSelectView.swift` | Modified | Updated to call new GameSession.selectCharacter() method |

### Packets Handled

Phase 3B handles 15+ packet types:

**Sent Packets**:
- `PACKET_CH_ENTER` - Initial char server authentication with account credentials
- `PACKET_PING` - Keepalive packet sent every 12 seconds
- `PACKET_CH_SELECT_CHAR` - Select character from slot
- `PACKET_CH_MAKE_CHAR` - Create new character
- `PACKET_CH_DELETE_CHAR3` - Delete character

**Received Packets**:
- `PACKET_HC_ACCEPT_ENTER` - Char server accepted with character list
- `PACKET_HC_REFUSE_ENTER` - Char server refused connection
- `PACKET_HC_NOTIFY_ZONESVR` - Map server info (triggers transition to map)
- `PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME` - Accessible maps notification
- `PACKET_HC_ACCEPT_MAKECHAR` - Character created successfully
- `PACKET_HC_REFUSE_MAKECHAR` - Character creation failed
- `PACKET_HC_ACCEPT_DELETECHAR` - Character deleted successfully
- `PACKET_HC_REFUSE_DELETECHAR` - Character deletion failed
- `PACKET_HC_DELETE_CHAR3` - Character deletion result (with result code)
- `PACKET_HC_DELETE_CHAR3_CANCEL` - Character deletion cancelled
- `PACKET_HC_DELETE_CHAR3_RESERVED` - Character deletion reserved with date
- `PACKET_HC_ACCEPT_ENTER2` - Additional enter response packet
- `PACKET_HC_SECOND_PASSWD_LOGIN` - Second password login packet
- `PACKET_HC_CHARLIST_NOTIFY` - Character list notification packet
- `PACKET_HC_BLOCK_CHARACTER` - Character block notification packet
- `PACKET_SC_NOTIFY_BAN` - Account banned notification

### What Should Work Now

1. GameSession no longer depends on CharSession
2. Character server flow uses Client directly with async packet streams
3. No event-based architecture for char server - direct packet handling
4. Keepalive timer managed by GameSession using Task
5. Character operations (select, create, delete) work via direct GameSession methods
6. UI views call GameSession methods directly instead of accessing charSession
7. Transition from char server to map server properly stops charClient
8. All char server functionality works identically to before
9. Tests pass without modification

### Testing Checklist

- [x] Build succeeds: `swift build` in RagnarokGame package
- [x] All tests pass
- [x] Character server connects and authenticates
- [x] Character list received and displayed
- [x] Keepalive packets sent every 12 seconds
- [x] Character selection works correctly
- [x] Character creation works correctly
- [x] Transition to map server disconnects char client properly

---

## Phase 3C: Refactor GameSession - Map Client

**Status**: ✅ COMPLETED & VERIFIED

**Date Completed**: 2026-01-08

### What Was Done

#### 1. Replaced MapSession with MapClient

In `Packages/RagnarokGame/Sources/RagnarokGame/GameSession.swift`:
- Removed `@ObservationIgnored var mapSession: MapSession?`
- Added `@ObservationIgnored var mapClient: Client?`
- Added `@ObservationIgnored var mapKeepaliveTask: Task<Void, Never>?`
- Added `@ObservationIgnored var currentMapServer: MapServerInfo?`

#### 2. Refactored startMapSession() to startMapClient()

Created new `startMapClient(character: CharacterInfo, mapServer: MapServerInfo)` method:
- Creates `Client` instance with map server address and port
- Spawns Task to handle `client.errorStream` - converts errors to ErrorMessage and appends to errorMessages
- Spawns Task to handle `client.packetStream` - calls `handleMapPacket()` for each packet
- Calls `client.connect()` to establish connection
- Sends initial `PACKET_CZ_ENTER` packet with account and character credentials
- Receives accountID (4 bytes) if PACKET_VERSION < 20070521
- Calls `startMapKeepalive()` to begin keepalive timer
- Stores client in `self.mapClient`

#### 3. Added startMapKeepalive() Method

Created new `startMapKeepalive()` method:
- Spawns Task that loops indefinitely
- Sleeps for 10 seconds using `try? await Task.sleep(for: .seconds(10))`
- Checks for cancellation with `guard !Task.isCancelled`
- Sends `PACKET_CZ_REQUEST_TIME` with elapsed time since start
- Stores task in `self.mapKeepaliveTask`

#### 4. Added handleMapPacket() Method

Created new `handleMapPacket(_ packet: any DecodablePacket)` method with 40+ packet type handlers:

**Map Connection Packets:**
- `PACKET_ZC_ACCEPT_ENTER` - Map server accepted connection
- `PACKET_ZC_RESTART_ACK` - Return to character select (type == 1)
- `PACKET_ZC_ACK_REQ_DISCONNECT` - Disconnect acknowledgment

**Utility Packets:**
- `PACKET_ZC_AID` - Account ID update
- `PACKET_ZC_PING_LIVE` - Respond with `PACKET_CZ_PING_LIVE`

**Map Change Packets:**
- `PACKET_ZC_NPCACK_MAPMOVE` - Map change notification, creates new MapScene with gameSession reference

**Player Packets:**
- `PACKET_ZC_NOTIFY_PLAYERMOVE` - Player movement
- `PACKET_ZC_STATUS` - Character basic status
- `PACKET_ZC_PAR_CHANGE` - Status property change (short)
- `PACKET_ZC_LONGPAR_CHANGE` - Status property change (int)
- `PACKET_ZC_LONGLONGPAR_CHANGE` - Status property change (long)
- `PACKET_ZC_STATUS_CHANGE` - Status change
- `PACKET_ZC_COUPLESTATUS` - Coupled status (value + value2)
- `PACKET_ZC_ATTACK_RANGE` - Attack range change

**Inventory Packets:**
- `PACKET_ZC_INVENTORY_START` - Inventory update begins
- `PACKET_ZC_INVENTORY_END` - Inventory update ends
- `packet_itemlist_normal` - Normal item list
- `packet_itemlist_equip` - Equipment item list

**Item Packets:**
- `PACKET_ZC_ITEM_ENTRY` - Item spawned on map
- `packet_dropflooritem` - Item dropped on floor
- `PACKET_ZC_ITEM_DISAPPEAR` - Item vanished from map
- `PACKET_ZC_ITEM_PICKUP_ACK` - Item pickup acknowledgment
- `PACKET_ZC_ITEM_THROW_ACK` - Item throw acknowledgment
- `PACKET_ZC_USE_ITEM_ACK` - Item use result, updates inventory
- `PACKET_ZC_REQ_WEAR_EQUIP_ACK` - Equip item result
- `PACKET_ZC_REQ_TAKEOFF_EQUIP_ACK` - Unequip item result

**Map Object Packets:**
- `packet_spawn_unit` - Map object spawned (standing)
- `packet_idle_unit` - Map object idle (standing)
- `packet_unit_walking` - Map object walking
- `PACKET_ZC_STOPMOVE` - Map object stopped
- `PACKET_ZC_NOTIFY_VANISH` - Map object vanished
- `PACKET_ZC_CHANGE_DIRECTION` - Direction changed
- `PACKET_ZC_SPRITE_CHANGE` - Sprite changed
- `PACKET_ZC_STATE_CHANGE` - State changed (body, health, effect)
- `PACKET_ZC_NOTIFY_ACT` - Action performed

**NPC Dialog Packets:**
- `PACKET_ZC_SAY_DIALOG` - NPC dialog message
- `PACKET_ZC_WAIT_DIALOG` - Wait for next dialog
- `PACKET_ZC_CLOSE_DIALOG` - Close dialog
- `PACKET_ZC_CLEAR_DIALOG` - Clear dialog
- `PACKET_ZC_MENU_LIST` - Menu list
- `PACKET_ZC_OPEN_EDITDLG` - Number input dialog
- `PACKET_ZC_OPEN_EDITDLGSTR` - Text input dialog
- `PACKET_ZC_SHOW_IMAGE` - Show NPC image
- `PACKET_ZC_COMPASS` - Minimap mark position

**Chat Packets:**
- `PACKET_ZC_NOTIFY_CHAT` - Public chat
- `PACKET_ZC_WHISPER` - Private message
- `PACKET_ZC_NOTIFY_PLAYERCHAT` - Self chat
- `PACKET_ZC_NPC_CHAT` - Channel/NPC chat
- `PACKET_ZC_NOTIFY_CHAT_PARTY` - Party chat
- `PACKET_ZC_GUILD_CHAT` - Guild chat
- `PACKET_ZC_NOTIFY_CLAN_CHAT` - Clan chat

**Achievement Packets:**
- `PACKET_ZC_ALL_ACH_LIST` - Achievement list
- `PACKET_ZC_ACH_UPDATE` - Achievement update

**Misc Packets:**
- `PACKET_SC_NOTIFY_BAN` - Account banned notification
- `PACKET_ZC_FRIENDS_LIST` - Friends list
- `PACKET_ZC_SHORTCUT_KEY_LIST` - Hotkey list
- `PACKET_ZC_EXTEND_BODYITEM_SIZE` - Inventory expansion
- `PACKET_ZC_STATUS_CHANGE_ACK` - Status change acknowledgment
- `PACKET_ZC_NOTIFY_CARTITEM_COUNTINFO` - Cart item count
- `PACKET_ZC_USE_SKILL` - Skill used
- `PACKET_ZC_PARTY_CONFIG` - Party configuration
- `PACKET_ZC_REPUTE_INFO` - Reputation info
- `PACKET_ZC_BROADCAST` - Broadcast message
- `PACKET_ZC_BROADCAST2` - Broadcast message (type 2)

#### 5. Added Map Operation Methods

Created public methods in GameSession for map operations:

**Connection Methods:**
- `notifyMapLoaded()` - Send `PACKET_CZ_NOTIFY_ACTORINIT` after map loads
- `returnToLastSavePoint()` - Send `PACKET_CZ_RESTART` (type 0)
- `returnToCharacterSelect()` - Send `PACKET_CZ_RESTART` (type 1)
- `requestExit()` - Send `PACKET_CZ_REQUEST_QUIT`

**Player Methods:**
- `requestMove(to:)` - Send `PACKET_CZ_REQUEST_MOVE`
- `requestAction(_:onTarget:)` - Send `PACKET_CZ_REQUEST_ACT`
- `changeDirection(headDirection:direction:)` - Send `PACKET_CZ_CHANGE_DIRECTION`
- `incrementStatusProperty(_:by:)` - Send `PACKET_CZ_STATUS_CHANGE` or `PACKET_CZ_ADVANCED_STATUS_CHANGE`

**Chat Methods:**
- `sendMessage(_:)` - Send `PACKET_CZ_REQUEST_CHAT` (supports party/guild/clan prefixes)

**Item Methods:**
- `pickUpItem(objectID:)` - Send `PACKET_CZ_ITEM_PICKUP`
- `throwItem(at:amount:)` - Send `PACKET_CZ_ITEM_THROW`
- `useItem(at:)` - Send `PACKET_CZ_USE_ITEM`
- `equipItem(at:location:)` - Send `PACKET_CZ_REQ_WEAR_EQUIP`
- `unequipItem(at:)` - Send `PACKET_CZ_REQ_TAKEOFF_EQUIP`

**NPC Methods:**
- `talkToNPC(npcID:)` - Send `PACKET_CZ_CONTACTNPC`
- `requestNextMessage()` - Send `PACKET_CZ_REQ_NEXT_SCRIPT`
- `closeDialog()` - Send `PACKET_CZ_CLOSE_DIALOG`
- `selectMenu(_:)` - Send `PACKET_CZ_CHOOSE_MENU`
- `cancelMenu()` - Send `PACKET_CZ_CHOOSE_MENU` (select 255)
- `confirmInput(_: Int32)` - Send `PACKET_CZ_INPUT_EDITDLG`
- `confirmInput(_: String)` - Send `PACKET_CZ_INPUT_EDITDLGSTR`

#### 6. Updated MapScene to Use GameSession

In `Packages/RagnarokGame/Sources/RagnarokGame/Core/MapScene.swift`:
- Replaced `mapSession: MapSession` property with `weak let gameSession: GameSession?`
- Updated `init()` to accept `gameSession: GameSession` instead of `mapClient: Client`
- Updated all interaction code to call GameSession methods:
  - `tileTapGesture` - calls `gameSession?.requestMove(to:)`
  - `mapObjectTapGesture` - calls `gameSession?.talkToNPC(npcID:)` for NPCs
  - `mapItemTapGesture` - calls `gameSession?.pickUpItem(objectID:)`
  - `load()` - calls `gameSession?.notifyMapLoaded()`
  - `raycast()` - calls appropriate GameSession methods for interactions
  - `onMovementValueChanged()` - calls `gameSession?.requestMove(to:)`
  - `talkToNearestNPC()` - calls `gameSession?.talkToNPC(npcID:)`
  - `engageMonster()` - calls `gameSession?.requestAction(_:onTarget:)`
  - `engageItem()` - calls `gameSession?.pickUpItem(objectID:)`
  - `movePlayerToward()` - calls `gameSession?.requestMove(to:)`
- Removed `import RagnarokNetwork` and `import RagnarokPackets` (no longer needed)

#### 7. Updated stopAllSessions() Method

Modified `stopAllSessions()` to properly clean up map client:
- Cancels `mapKeepaliveTask` and sets to nil
- Disconnects `mapClient` and sets to nil
- Continues to handle charClient and loginClient cleanup

#### 8. Updated startCharClient() Method

Modified `handleCharPacket()` in `startCharClient()` to call `startMapClient()` instead of `startMapSession()` when transitioning to map server.

### Files Modified

| File | Type | Description |
|------|------|-------------|
| `Packages/RagnarokGame/Sources/RagnarokGame/GameSession.swift` | Modified | Complete refactor of map flow from MapSession to Client |
| `Packages/RagnarokGame/Sources/RagnarokGame/Core/MapScene.swift` | Modified | Updated to use GameSession methods instead of direct Client access |

### Packets Handled

Phase 3C handles 40+ packet types covering all map gameplay:

**Sent Packets** (16 types):
- Connection: `PACKET_CZ_ENTER`, `PACKET_CZ_NOTIFY_ACTORINIT`, `PACKET_CZ_REQUEST_TIME`, `PACKET_CZ_RESTART`, `PACKET_CZ_REQUEST_QUIT`
- Player: `PACKET_CZ_REQUEST_MOVE`, `PACKET_CZ_REQUEST_ACT`, `PACKET_CZ_CHANGE_DIRECTION`, `PACKET_CZ_STATUS_CHANGE`, `PACKET_CZ_ADVANCED_STATUS_CHANGE`
- Chat: `PACKET_CZ_REQUEST_CHAT`
- Items: `PACKET_CZ_ITEM_PICKUP`, `PACKET_CZ_ITEM_THROW`, `PACKET_CZ_USE_ITEM`, `PACKET_CZ_REQ_WEAR_EQUIP`, `PACKET_CZ_REQ_TAKEOFF_EQUIP`
- NPC: `PACKET_CZ_CONTACTNPC`, `PACKET_CZ_REQ_NEXT_SCRIPT`, `PACKET_CZ_CLOSE_DIALOG`, `PACKET_CZ_CHOOSE_MENU`, `PACKET_CZ_INPUT_EDITDLG`, `PACKET_CZ_INPUT_EDITDLGSTR`
- Keepalive: `PACKET_CZ_PING_LIVE`

**Received Packets** (40+ types):
- Connection: `PACKET_ZC_ACCEPT_ENTER`, `PACKET_ZC_RESTART_ACK`, `PACKET_ZC_ACK_REQ_DISCONNECT`, `PACKET_ZC_AID`, `PACKET_ZC_PING_LIVE`
- Map: `PACKET_ZC_NPCACK_MAPMOVE`
- Player: `PACKET_ZC_NOTIFY_PLAYERMOVE`, `PACKET_ZC_STATUS`, `PACKET_ZC_PAR_CHANGE`, `PACKET_ZC_LONGPAR_CHANGE`, `PACKET_ZC_LONGLONGPAR_CHANGE`, `PACKET_ZC_STATUS_CHANGE`, `PACKET_ZC_COUPLESTATUS`, `PACKET_ZC_ATTACK_RANGE`
- Inventory: `PACKET_ZC_INVENTORY_START`, `PACKET_ZC_INVENTORY_END`, `packet_itemlist_normal`, `packet_itemlist_equip`
- Items: `PACKET_ZC_ITEM_ENTRY`, `packet_dropflooritem`, `PACKET_ZC_ITEM_DISAPPEAR`, `PACKET_ZC_ITEM_PICKUP_ACK`, `PACKET_ZC_ITEM_THROW_ACK`, `PACKET_ZC_USE_ITEM_ACK`, `PACKET_ZC_REQ_WEAR_EQUIP_ACK`, `PACKET_ZC_REQ_TAKEOFF_EQUIP_ACK`
- Objects: `packet_spawn_unit`, `packet_idle_unit`, `packet_unit_walking`, `PACKET_ZC_STOPMOVE`, `PACKET_ZC_NOTIFY_VANISH`, `PACKET_ZC_CHANGE_DIRECTION`, `PACKET_ZC_SPRITE_CHANGE`, `PACKET_ZC_STATE_CHANGE`, `PACKET_ZC_NOTIFY_ACT`
- NPC Dialogs: `PACKET_ZC_SAY_DIALOG`, `PACKET_ZC_WAIT_DIALOG`, `PACKET_ZC_CLOSE_DIALOG`, `PACKET_ZC_CLEAR_DIALOG`, `PACKET_ZC_MENU_LIST`, `PACKET_ZC_OPEN_EDITDLG`, `PACKET_ZC_OPEN_EDITDLGSTR`, `PACKET_ZC_SHOW_IMAGE`, `PACKET_ZC_COMPASS`
- Chat: `PACKET_ZC_NOTIFY_CHAT`, `PACKET_ZC_WHISPER`, `PACKET_ZC_NOTIFY_PLAYERCHAT`, `PACKET_ZC_NPC_CHAT`, `PACKET_ZC_NOTIFY_CHAT_PARTY`, `PACKET_ZC_GUILD_CHAT`, `PACKET_ZC_NOTIFY_CLAN_CHAT`
- Achievements: `PACKET_ZC_ALL_ACH_LIST`, `PACKET_ZC_ACH_UPDATE`
- Misc: `PACKET_SC_NOTIFY_BAN`, `PACKET_ZC_FRIENDS_LIST`, `PACKET_ZC_SHORTCUT_KEY_LIST`, `PACKET_ZC_EXTEND_BODYITEM_SIZE`, `PACKET_ZC_STATUS_CHANGE_ACK`, `PACKET_ZC_NOTIFY_CARTITEM_COUNTINFO`, `PACKET_ZC_USE_SKILL`, `PACKET_ZC_PARTY_CONFIG`, `PACKET_ZC_REPUTE_INFO`, `PACKET_ZC_BROADCAST`, `PACKET_ZC_BROADCAST2`

### What Should Work Now

1. GameSession no longer depends on MapSession
2. Map server flow uses Client directly with async packet streams
3. No event-based architecture for map server - direct packet handling
4. Keepalive timer managed by GameSession using Task (sends `PACKET_CZ_REQUEST_TIME` every 10 seconds)
5. MapScene uses GameSession as a facade for all network operations
6. All map operations (movement, combat, items, NPCs, chat) work via GameSession methods
7. GameSession provides a clean API for all map-related actions
8. Transition from char server to map server properly stops charClient and starts mapClient
9. Transition back to character select properly stops mapClient
10. All map server functionality works identically to before
11. Tests pass without modification

### Testing Checklist

- [x] Build succeeds: `swift build` in RagnarokGame package
- [x] All tests pass
- [x] Map client connects and authenticates
- [x] Map loads and displays correctly
- [x] Keepalive packets sent every 10 seconds
- [x] Player movement works correctly
- [x] NPC interactions work correctly
- [x] Item pickup works correctly
- [x] Combat works correctly
- [x] Inventory updates work correctly
- [x] Chat works correctly
- [x] Transition to character select disconnects map client properly

---

## Phase 4: Refactor ChatSession

**Status**: ✅ COMPLETED & VERIFIED

**Date Completed**: 2026-01-08

### What Was Done

#### 1. Replaced Session Properties with Client Properties

In `RagnarokOffline/ChatClient/ChatSession.swift`:
- Removed `loginSession: LoginSession?`
- Removed `charSession: CharSession?`
- Removed `mapSession: MapSession?`
- Added `loginClient: Client?`
- Added `loginKeepaliveTask: Task<Void, Never>?`
- Added `charClient: Client?`
- Added `charKeepaliveTask: Task<Void, Never>?`
- Added `mapClient: Client?`
- Added `mapKeepaliveTask: Task<Void, Never>?`
- Added `username: String?` to store username for login keepalive packets

#### 2. Refactored Login Client Flow

Replaced `startLoginSession()` with `startLoginClient()`:
- Creates `Client` instance with login server address and port
- Spawns Task to handle `client.errorStream` - appends errors to messages
- Spawns Task to handle `client.packetStream` - calls `handleLoginPacket()` for each packet
- Calls `client.connect()` to establish connection
- Stores client in `self.loginClient`

Created `handleLoginPacket(_ packet: any DecodablePacket)`:
- Pattern matches on packet types using `switch` and `case let packet as PacketType:`
- Handles `PACKET_AC_ACCEPT_LOGIN`:
  - Converts packet to `AccountInfo(from: packet)`
  - Maps char_servers to `CharServerInfo(from:)`
  - Updates account and charServers
  - Changes phase to `.selectCharServer`
  - Appends success message and char server list to messages
  - Calls `startLoginKeepalive()` to begin keepalive timer
- Handles `PACKET_AC_REFUSE_LOGIN`:
  - Converts packet to `LoginRefusedMessage(from: packet)`
  - Looks up localized message from messageStringTable
  - Appends error message to messages
- Handles `PACKET_SC_NOTIFY_BAN`:
  - Converts packet to `BannedMessage(from: packet)`
  - Looks up localized message from messageStringTable
  - Appends error message to messages

Created `startLoginKeepalive()`:
- Spawns Task that loops indefinitely
- Sleeps for 10 seconds using `try? await Task.sleep(for: .seconds(10))`
- Checks for cancellation with `guard !Task.isCancelled`
- Sends `PACKET_CA_CONNECT_INFO_CHANGED` with stored username
- Stores task in `self.loginKeepaliveTask`

#### 3. Refactored Char Client Flow

Replaced `startCharSession()` with `startCharClient()`:
- Cancels and disconnects login client before transitioning
- Creates `Client` instance with char server address and port
- Spawns Task to handle `client.errorStream` - appends errors to messages
- Spawns Task to handle `client.packetStream` - calls `handleCharPacket()` for each packet
- Calls `client.connect()` to establish connection
- Sends initial `PACKET_CH_ENTER` packet with account credentials
- Receives accountID (4 bytes) and updates account using `receiveDataAndPacket()`
- Calls `startCharKeepalive()` to begin keepalive timer
- Stores client in `self.charClient`

Created `handleCharPacket(_ packet: any DecodablePacket)`:
- Pattern matches on packet types using `switch` and `case let packet as PacketType:`
- Handles `PACKET_HC_ACCEPT_ENTER`:
  - Converts packet to character list
  - Updates characters array
  - Changes phase to `.selectCharacter`
  - Appends success message and character details to messages
- Handles `PACKET_HC_REFUSE_ENTER`:
  - Appends error message
- Handles `PACKET_HC_NOTIFY_ZONESVR`:
  - Extracts map server info and map name
  - Changes phase to `.map`
  - Appends map entry message
  - Stops charClient and calls `startMapClient()`
- Handles `PACKET_HC_ACCEPT_MAKECHAR`:
  - Appends success message
- Handles `PACKET_HC_REFUSE_MAKECHAR`:
  - Appends error message
- Handles `PACKET_HC_ACCEPT_DELETECHAR`, `PACKET_HC_REFUSE_DELETECHAR`, `PACKET_HC_DELETE_CHAR3`, `PACKET_HC_DELETE_CHAR3_CANCEL`, `PACKET_HC_DELETE_CHAR3_RESERVED`:
  - Placeholder handling (no action needed for chat client)
- Handles `PACKET_SC_NOTIFY_BAN`:
  - Converts packet to `BannedMessage(from: packet)`
  - Looks up localized message
  - Appends error message to messages

Created `startCharKeepalive()`:
- Spawns Task that loops indefinitely
- Sleeps for 12 seconds using `try? await Task.sleep(for: .seconds(12))`
- Checks for cancellation with `guard !Task.isCancelled`
- Sends `PACKET_PING` with account ID
- Stores task in `self.charKeepaliveTask`

#### 4. Refactored Map Client Flow

Replaced `startMapSession()` with `startMapClient()`:
- Cancels and disconnects char client before transitioning
- Creates `Client` instance with map server address and port
- Spawns Task to handle `client.errorStream` - appends errors to messages
- Spawns Task to handle `client.packetStream` - calls `handleMapPacket()` for each packet
- Calls `client.connect()` to establish connection
- Sends initial `PACKET_CZ_ENTER` packet with account and character credentials
- Conditionally receives accountID (4 bytes) if `PACKET_VERSION < 20070521`, otherwise calls `receivePacket()`
- Calls `startMapKeepalive()` to begin keepalive timer
- Stores client in `self.mapClient`

Created `handleMapPacket(_ packet: any DecodablePacket)`:
- Pattern matches on packet types using `switch` and `case let packet as PacketType:`
- Handles `PACKET_ZC_ACCEPT_ENTER`:
  - Map server accepted connection (no action needed)
- Handles `PACKET_ZC_NPCACK_MAPMOVE`:
  - Extracts map name and position
  - Updates playerPosition
  - Appends map changed message
  - Sends `PACKET_CZ_NOTIFY_ACTORINIT` to notify map loaded
- Handles `PACKET_ZC_NOTIFY_PLAYERMOVE`:
  - Converts packet to `MoveData(from: packet.moveData)`
  - Updates playerPosition
  - Appends player moved message
- Handles `PACKET_ZC_NOTIFY_CHAT`:
  - Converts packet to `ChatMessage(from: packet)`
  - Appends chat message content to messages
- Handles `PACKET_ZC_PING_LIVE`:
  - Responds with `PACKET_CZ_PING_LIVE` keepalive packet
- Handles `PACKET_SC_NOTIFY_BAN`:
  - Converts packet to `BannedMessage(from: packet)`
  - Looks up localized message
  - Appends error message to messages

Created `startMapKeepalive()`:
- Records start time
- Spawns Task that loops indefinitely
- Sleeps for 10 seconds using `try? await Task.sleep(for: .seconds(10))`
- Checks for cancellation with `guard !Task.isCancelled`
- Sends `PACKET_CZ_REQUEST_TIME` with elapsed time since start
- Stores task in `self.mapKeepaliveTask`

#### 5. Updated Command Handlers

Modified `sendCommand()` to send packets directly via clients:

**Login Command**:
- Stores username in `self.username`
- Calls `startLoginClient()`
- Creates and sends `PACKET_CA_LOGIN` with username, password
- Calls `loginClient?.receivePacket()` to trigger packet reception

**Select Char Server Command**:
- Validates server number
- Calls `startCharClient(charServer)` to connect to selected char server

**Make Character Command**:
- Creates character info from parameters
- Creates and sends `PACKET_CH_MAKE_CHAR` with character details
- Sends via `charClient?.sendPacket(packet)`

**Select Character Command**:
- Creates and sends `PACKET_CH_SELECT_CHAR` with slot number
- Sends via `charClient?.sendPacket(packet)`

**Movement Commands** (moveUp, moveDown, moveLeft, moveRight):
- Creates and sends `PACKET_CZ_REQUEST_MOVE` with position coordinates
- Sends via `mapClient?.sendPacket(packet)`

Modified `sendMessage()`:
- Creates and sends `PACKET_CZ_REQUEST_CHAT` with message content
- Sends via `mapClient?.sendPacket(packet)`

#### 6. Client Lifecycle Management

Each client transition properly cancels keepalive tasks and disconnects previous client:
- **Login → Char**: Stops loginClient and loginKeepaliveTask before starting charClient
- **Char → Map**: Stops charClient and charKeepaliveTask before starting mapClient

### Files Modified

| File | Type | Description |
|------|------|-------------|
| `RagnarokOffline/ChatClient/ChatSession.swift` | Modified | Complete refactor from Session-based to Client-based architecture |

### Packets Handled

Phase 4 handles 15+ packet types across all three server connections:

**Login Packets** (3 types):
- `PACKET_CA_LOGIN` (sent) - Login authentication request
- `PACKET_CA_CONNECT_INFO_CHANGED` (sent) - Keepalive packet every 10 seconds
- `PACKET_AC_ACCEPT_LOGIN` (received) - Successful login response
- `PACKET_AC_REFUSE_LOGIN` (received) - Login refused response
- `PACKET_SC_NOTIFY_BAN` (received) - Account banned notification

**Char Packets** (8 types):
- `PACKET_CH_ENTER` (sent) - Initial char server authentication
- `PACKET_PING` (sent) - Keepalive packet every 12 seconds
- `PACKET_CH_MAKE_CHAR` (sent) - Create new character
- `PACKET_CH_SELECT_CHAR` (sent) - Select character from slot
- `PACKET_HC_ACCEPT_ENTER` (received) - Char server accepted with character list
- `PACKET_HC_REFUSE_ENTER` (received) - Char server refused connection
- `PACKET_HC_NOTIFY_ZONESVR` (received) - Map server info (triggers transition to map)
- `PACKET_HC_ACCEPT_MAKECHAR` (received) - Character created successfully
- `PACKET_HC_REFUSE_MAKECHAR` (received) - Character creation failed
- `PACKET_SC_NOTIFY_BAN` (received) - Account banned notification

**Map Packets** (7 types):
- `PACKET_CZ_ENTER` (sent) - Initial map server authentication
- `PACKET_CZ_NOTIFY_ACTORINIT` (sent) - Notify map loaded
- `PACKET_CZ_REQUEST_TIME` (sent) - Keepalive packet every 10 seconds
- `PACKET_CZ_REQUEST_MOVE` (sent) - Player movement request
- `PACKET_CZ_REQUEST_CHAT` (sent) - Chat message
- `PACKET_CZ_PING_LIVE` (sent) - Respond to server ping
- `PACKET_ZC_ACCEPT_ENTER` (received) - Map server accepted connection
- `PACKET_ZC_NPCACK_MAPMOVE` (received) - Map change notification
- `PACKET_ZC_NOTIFY_PLAYERMOVE` (received) - Player movement notification
- `PACKET_ZC_NOTIFY_CHAT` (received) - Chat message received
- `PACKET_ZC_PING_LIVE` (received) - Server keepalive ping
- `PACKET_SC_NOTIFY_BAN` (received) - Account banned notification

### What Should Work Now

1. ChatSession no longer depends on LoginSession, CharSession, or MapSession
2. All network flows use Client directly with async packet streams
3. No event-based architecture - direct packet handling with pattern matching
4. Keepalive timers managed by ChatSession using Tasks
5. All command handlers send packets directly via clients
6. Clean client lifecycle management with proper cleanup on transitions
7. All chat client functionality works identically to before
8. Tests pass without modification

### Testing Checklist

- [x] Build succeeds
- [x] All tests pass
- [x] Login client connects and authenticates
- [x] Keepalive packets sent at correct intervals (10s login, 12s char, 10s map)
- [x] Character server connects and displays character list
- [x] Map client connects and handles basic packets
- [x] Chat messages work correctly
- [x] Client transitions properly disconnect previous clients

---

## Remaining Phases

- [ ] **Phase 5**: Remove Sessions, Events, and Subscription Infrastructure
- [ ] **Phase 6**: Update Package Dependencies
