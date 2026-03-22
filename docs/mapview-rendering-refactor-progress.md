# MapView Rendering Refactor Progress

## Phase 1 — Render-Engine Entry Point and Type Boundaries

**Completed:** 2026-03-20
**Branch:** `feature/mapview-rendering-refactor`

### What was done

Introduced the abstraction layer that lets `MapView` hand off rendering to an engine-specific host without knowing about concrete render views. No rendering behavior changed — `MapRenderHost` still routes every request to `MapSceneARView` (RealityKit/ARView) on iOS and macOS. The visionOS path continues to open an immersive space and show a placeholder.

### New files

All new files live under `Packages/RagnarokGame/Sources/RagnarokGame/Client/Rendering/`.

#### `MapRenderEngine.swift`

```swift
public enum MapRenderEngine: CaseIterable, Sendable {
    case metal
    case realityKit
}
```

Two cases only. `CaseIterable` is there for a future settings UI picker. There is no `.automatic` case — platform default is expressed through `MapRenderConfiguration.default` instead.

#### `MapRenderConfiguration.swift`

```swift
public struct MapRenderConfiguration: Sendable {
    public static var `default`: MapRenderConfiguration {
        #if os(visionOS)
        MapRenderConfiguration(engine: .realityKit)
        #else
        MapRenderConfiguration(engine: .metal)
        #endif
    }

    public var engine: MapRenderEngine

    public init(engine: MapRenderEngine) { ... }
}
```

`default` is a computed `static var` so the `#if os(visionOS)` check happens at each call site rather than at module initialisation time. This is the single platform-dispatch point — nothing else in the stack needs to import `#if os(visionOS)` to pick an engine.

#### `MapRenderingSurface.swift`

Marker protocol (`View` subtype) that concrete surface views will conform to in later phases. Has no requirements yet.

#### `MapRenderHost.swift`

```swift
struct MapRenderHost: View {
    var scene: MapScene
    var configuration: MapRenderConfiguration

    #if !os(visionOS)
    var onSceneUpdate: (ARView) -> Void
    #endif

    var body: some View {
        switch configuration.engine {
        case .metal:    metalSurface
        case .realityKit: realityKitSurface
        }
    }
    ...
}
```

Pure routing view — no `@State`, no `AnyView`. Both `metalSurface` and `realityKitSurface` currently resolve to `MapSceneARView` on iOS/macOS and a `Text("Game")` placeholder on visionOS. The Metal branch will be rewired in Phase 9.

`import RealityKit` is retained because `onSceneUpdate: (ARView) -> Void` is still needed until Phase 5 removes the `ARView.project`-based overlay path.

### Modified files

#### `MapView.swift`

- Added `var renderConfiguration: MapRenderConfiguration = .default`
- Replaced the inline `#if os(visionOS) / MapSceneARView` block with `MapRenderHost(scene:configuration:onSceneUpdate:)`
- `updateOverlay(arView:)` and `import RealityKit` are untouched — still needed for HUD projection

#### `GameView.swift`

- Added `public var renderConfiguration: MapRenderConfiguration = .default`
- Added `renderConfiguration` parameter to `init` (default `.default` so all existing call sites compile without changes)
- Passes `renderConfiguration` down to `MapView`

### What did not change

- **`SettingsModel`** — engine selection is not exposed in the settings UI yet
- **`GameClientView` / `macOSApp`** — both call `GameView` without a `renderConfiguration` argument and pick up `.default` automatically
- **`GameSession`** — holds `MapScene` only; engine selection is a view-layer concern
- **Runtime behavior** — map loads, camera, thumbstick, overlays, and visionOS immersive space are all identical to before

### Known temporary state

`MapRenderHost` routes `.metal` to `MapSceneARView` on iOS/macOS. This is intentional scaffolding. The Metal backend (`MTKView`-based) will replace this in Phase 9. Until then, selecting `.metal` or `.realityKit` produces the same result on iOS/macOS.

### Next phase

**Phase 3 — Observable MapScene.**
Introduce `@Observable` on `MapScene` so SwiftUI views can react to `cameraState` changes without polling, and lay the groundwork for the camera follow target (`targetPosition`) field.

---

## Phase 2 — Extract Camera State and Input Intent

**Completed:** 2026-03-20
**Branch:** `feature/mapview-rendering-refactor`

### What was done

Consolidated the three scattered camera properties on `MapScene` (`horizontalAngle`, `verticalAngle`, `distance`) into a single `MapCameraState` value type. Defined typed intent types for input. Made `MapSceneARViewController` an input bridge instead of a camera owner. No rendering behavior changed.

Also fixed a pre-existing visionOS bug: `MapScene.distance` previously defaulted to `100` but was never observed on visionOS (the `WorldCameraComponent` was hard-coded to `radius = 15` in `setupWorldCamera` with no matching source of truth). `MapCameraState.default.distance` is now `15` on visionOS, so the two are in sync.

### New files

All new files live under `Packages/RagnarokGame/Sources/RagnarokGame/Engine/Runtime/`. This directory is new — the three files create it implicitly. No `Package.swift` changes were needed.

#### `MapCameraState.swift`

```swift
public struct MapCameraState: Sendable {
    public var azimuth: Float     // was horizontalAngle
    public var elevation: Float   // was verticalAngle
    public var distance: Float

    public static var `default`: MapCameraState {
        #if os(visionOS)
        MapCameraState(azimuth: 0, elevation: .pi / 12, distance: 15)
        #else
        MapCameraState(azimuth: 0, elevation: .pi / 4, distance: 100)
        #endif
    }
}
```

`Float.pi / 4` = 45° (iOS/macOS default elevation), `Float.pi / 12` = 15° (visionOS). No imports beyond Swift stdlib — avoids pulling SGLMath into the runtime layer. `targetPosition: SIMD3<Float>` is reserved for Phase 3+.

#### `MapInputIntent.swift`

```swift
import CoreGraphics

public struct MapInputIntent: Sendable {
    public var movementValue: CGPoint
}
```

Typed wrapper for thumbstick/joystick input. Makes the view-to-runtime contract explicit.

#### `MapInteractionIntent.swift`

```swift
import simd

public enum MapInteractionIntent: Sendable {
    case raycast(origin: SIMD3<Float>, direction: SIMD3<Float>)
}
```

Type stub for tap/click interactions. Not yet wired into `MapScene` — that happens in Phase 4.

### Modified files

#### `MapScene.swift`

- Removed `horizontalAngle`, `verticalAngle` (both platform variants), and `distance`
- Added `var cameraState: MapCameraState = .default` with a `didSet` that writes only changed fields to `WorldCameraComponent` (per-field guards avoid redundant RealityKit ECS writes during gestures that only move one axis)
- `setupWorldCamera` reads `cameraState.elevation` for the initial elevation
- `onMovementValueChanged` reads `cameraState.azimuth` for the rotation calculation
- Added `func handle(_ intent: MapInputIntent)` as the public input bridge; `onMovementValueChanged` stays `private`

The `didSet` on `cameraState` skips the elevation write on visionOS (`#if !os(visionOS)`) because `WorldCameraComponent.elevation` has no effect in an immersive space — the system controls pitch there.

#### `MapSceneARView.swift`

iOS and macOS blocks both:
- Renamed `horizontalAngle` → `baseAzimuth`, `verticalAngle` → `baseElevation`, `distance` → `baseDistance`. These instance vars are retained because UIKit/AppKit gesture handlers receive `.began` and `.changed` as separate calls with no way to pass state between them. The rename makes their role explicit: they are gesture-start baselines, not camera state.
- All gesture handlers read from and write to `scene.cameraState` directly
- `handleDoubleTap` (iOS) resets `scene.cameraState.azimuth = 0` and `scene.cameraState.elevation = .pi / 4`, then syncs the baselines
- Elevation clamps changed from `radians(15)...radians(60)` to `.pi / 12 ... .pi / 3` — same values, no SGLMath dependency
- Azimuth wrap changed from `radians(360)` to `.pi * 2` — same value, no SGLMath dependency
- Removed `import SGLMath` (no longer used)

#### `MapSceneRealityView.swift`

- Removed `@State private var distance: Float = 100`
- Added `@State private var baseDistance: Float = MapCameraState.default.distance` — seeds from the canonical default (15 on visionOS) rather than the hard-coded 100 that was wrong
- `MagnifyGesture.onChanged` writes to `scene.cameraState.distance`
- `MagnifyGesture.onEnded` snapshots `scene.cameraState.distance` back into `baseDistance`

#### `MapView.swift`

- Thumbstick timer callback changed from `scene.onMovementValueChanged(movementValue:)` to `scene.handle(MapInputIntent(movementValue:))`

### What did not change

- **Rendering behavior** — camera still orbits, zooms, and tilts identically on all platforms
- **`WorldCameraComponent` write path** — still driven by `didSet`; no new observation infrastructure
- **`GameSession` / `GameView`** — neither touches camera state
- **visionOS immersive space** — `MapScene` is loaded the same way; only the distance default is now correct

### Known temporary state

`onMovementValueChanged` is still internal to `MapScene`. It will remain so — `handle(_:)` is the stable public API. `MapInteractionIntent` is defined but not yet wired into `MapScene`; that happens in Phase 4.

---

## Phase 3 — Extract Scene State Models

**Completed:** 2026-03-20
**Branch:** `feature/mapview-rendering-refactor`

### What was done

Introduced an engine-agnostic scene state layer. All packet-driven events now write to `MapScene.state` first, then continue to update the RealityKit entity tree as a mirrored path. No rendering behavior changed.

### New files

All new files live under `Packages/RagnarokGame/Sources/RagnarokGame/Engine/Runtime/`.

#### `MapObjectState.swift`

```swift
public struct MapObjectState: Identifiable, Sendable {
    public let id: UInt32
    public var object: MapObject
    public var gridPosition: SIMD2<Int>
    public var hp: Int
    public var maxHp: Int
    public var sp: Int?     // non-nil for the local player only
    public var maxSp: Int?  // non-nil for the local player only
    public var isVisible: Bool
}
```

Mirrors the data previously scattered across `MapObjectComponent`, `GridPositionComponent`, `HealthPointsComponent`, and `SpellPointsComponent` on a RealityKit entity. No ECS dependency.

#### `MapItemState.swift`

```swift
public struct MapItemState: Identifiable, Sendable {
    public let id: UInt32
    public var item: MapItem
    public var gridPosition: SIMD2<Int>
}
```

Mirrors `MapItemComponent` + `GridPositionComponent` without importing `RealityKit`.

#### `MapSelectionState.swift`

```swift
public struct MapSelectionState: Sendable {
    public var selectedPosition: SIMD2<Int>?
}
```

Set whenever the player clicks a tile (both `tileTapGesture` and the `raycast` ground-hit path).

#### `MapDamageEffect.swift`

```swift
public struct MapDamageEffect: Identifiable, Sendable {
    public let id: UUID
    public let targetObjectID: UInt32
    public let amount: Int
    public let delay: TimeInterval
}
```

Records damage numbers as they arrive from attack and skill packets. Effects are queued in `MapSceneState.damageEffects` and consumed via `drainDamageEffects()`. The RealityKit path still creates `DamageDigitEntity` objects in parallel — the queue is not yet consumed by any backend.

#### `MapSceneState.swift`

```swift
@MainActor
@Observable
public final class MapSceneState {
    public var player: MapObjectState
    public var objects: [UInt32: MapObjectState] = [:]
    public var items: [UInt32: MapItemState] = [:]
    public var selection: MapSelectionState = MapSelectionState()
    public var damageEffects: [MapDamageEffect] = []

    public func drainDamageEffects() -> [MapDamageEffect]
}
```

`@Observable` so SwiftUI views can react to state changes without polling. `@MainActor` so all mutations are serialized. `objects` and `items` are keyed by object ID for O(1) access.

### Modified files

#### `MapScene.swift`

- Added `let state: MapSceneState` (initialized in `init()` from `player` and `character`)
- `init()` builds the initial `MapObjectState` for the player with HP, SP, and visibility from `CharacterInfo`
- `tileTapGesture.onEnded` sets `state.selection.selectedPosition` before calling `requestMove`
- `raycast()` sets `state.selection.selectedPosition` on ground-hit before calling `requestMove`
- All `MapEventHandlerProtocol` methods write to `state` first:
  - `onReceivePacket(_:PACKET_ZC_PAR_CHANGE)` — updates `state.player.hp/maxHp/sp/maxSp`
  - `onReceivePacket(_:PACKET_ZC_HP_INFO)` — updates player or object HP in state
  - `onPlayerMoved` — updates `state.player.gridPosition`
  - `onMapObjectSpawned` — inserts or replaces object in `state.objects`
  - `onMapObjectMoved` — updates or inserts object position in `state.objects`
  - `onMapObjectStopped` — updates object grid position in `state.objects`
  - `onMapObjectVanished` — removes object from `state.objects`
  - `onMapObjectStateChanged` — updates `isVisible` in `state.objects`
  - `onMapObjectActionPerformed` — appends `MapDamageEffect` entries before the entity path
  - `onMapObjectSkillPerformed` — appends `MapDamageEffect` entries before the entity path
  - `onItemSpawned` — inserts item into `state.items`
  - `onItemVanished` — removes item from `state.items`

#### `GameSession.swift`

- Added `public var mapSceneState: MapSceneState?` as a convenience accessor (`mapScene?.state`), so callers can read object and item state without navigating the phase enum.

### What did not change

- **RealityKit entity tree** — all existing entity updates remain intact as the mirrored path
- **Overlay** — `MapSceneOverlay` is still the source for HUD data; it will be replaced in Phase 5
- **Rendering behavior** — camera, thumbstick, overlays, and visionOS immersive space are all identical to before

### Known temporary state

- `damageEffects` accumulates but is never drained in this phase. The Metal backend (Phase 11) will call `drainDamageEffects()` each frame. The RealityKit entity path still creates damage digit entities independently.
- `MapSceneOverlay` (used by the HUD) is still updated separately in `MapView`; it will be retired in Phase 5 when overlay projection is extracted.
- `state.player.gridPosition` reflects the server-confirmed destination on `onPlayerMoved`, not the interpolated position during walking.

### Next phase

**Phase 5 — Extract Overlay and Projector Interfaces.**
Remove the current HUD dependency on `ARView.project` and make projection a backend capability.

---

## Phase 4 — Extract Gameplay Interaction and Targeting Logic

**Completed:** 2026-03-20
**Branch:** `feature/mapview-rendering-refactor`

### What was done

Moved all nearest-target selection and movement-to-target logic off the RealityKit entity tree and onto `MapSceneState`. Gameplay logic no longer requires a backend entity to exist behind every target. The RealityKit entity tree remains as a mirrored path for rendering and walking animation.

### New files

#### `Engine/Runtime/MapInteractionResolver.swift`

```swift
enum MapMovementDecision {
    case alreadyInRange
    case moveTo(SIMD2<Int>)
    case noPath
}

struct MapInteractionResolver {
    let pathfinder: Pathfinder

    func decideMovement(
        from playerPosition: SIMD2<Int>,
        toward targetPosition: SIMD2<Int>,
        within range: Int
    ) -> MapMovementDecision
}
```

Pure Swift path-finding decision service. Wraps `Pathfinder` and exposes a single `decideMovement` method that returns one of three cases: already in range (call the action immediately), move to a destination (walk first), or no path found. Extracted from the body of the old `movePlayerToward(targetEntity:within:onArrival:)`.

`MapMovementDecision` lives in the same file because it is the resolver's sole return type.

### Modified files

#### `Engine/Runtime/MapSceneState.swift`

Added an extension with three targeting methods:

```swift
extension MapSceneState {
    func nearestMonster(fromPosition position: SIMD2<Int>) -> MapObjectState?
    func nearestNPC(fromPosition position: SIMD2<Int>) -> MapObjectState?
    func nearestItem(fromPosition position: SIMD2<Int>) -> MapItemState?
}
```

Each method scans the relevant state dictionary (`objects` or `items`) with an O(n) min search keyed on Chebyshev-distance squared. No entity dependency. `distanceSquared` is a private helper in the same extension.

These were initially in a separate `MapTargetingService` struct, then moved here because the state already owns the data and the methods are a natural fit as queries on that state.

#### `Engine/ECS/Components/LockOnComponent.swift`

Removed the unused `targetEntity: Entity` field:

```swift
// Before
struct LockOnComponent: Component {
    var targetEntity: Entity
    var attackRange: Float
    var action: () -> Void
}

// After
struct LockOnComponent: Component {
    var attackRange: Float
    var action: () -> Void
}
```

`LockOnSystem` never read `targetEntity` — it only called `action()` when `WalkingComponent` was removed. The field was dead weight from the original implementation.

#### `Engine/Scene/MapScene.swift`

Added `private let interactionResolver: MapInteractionResolver`, initialized in `init()` after `pathfinder`.

**Targeting methods** — replaced entity-tree scans with state queries:

```swift
// Before
func attackNearestMonster() {
    let playerPosition = playerEntity.gridPosition
    let monsters = rootEntity.children.filter {
        $0.components[MapObjectComponent.self]?.mapObject.type == .monster
    }
    if let targetEntity = monsters.min(by: { ... }) {
        engageMonster(targetEntity: targetEntity)
    }
}

// After
func attackNearestMonster() {
    if let target = state.nearestMonster(fromPosition: state.player.gridPosition) {
        engageMonster(target)
    }
}
```

Same pattern for `useSkillOnNearestMonster`, `pickUpNearestItem`, and `talkToNearestNPC`.

**Engage methods** — replaced entity parameters with state value types:

```swift
// Before
private func engageMonster(targetEntity: Entity) {
    guard let mapObject = targetEntity.components[MapObjectComponent.self]?.mapObject else { return }
    movePlayerToward(targetEntity: targetEntity, within: 1) {
        self.gameSession?.requestAction(._repeat, onTarget: mapObject.objectID)
    }
}

// After
private func engageMonster(_ target: MapObjectState) {
    movePlayerToward(targetPosition: target.gridPosition, within: 1) {
        self.gameSession?.requestAction(._repeat, onTarget: target.id)
    }
}
```

Same pattern for `engageMonster(_:skill:)` and `engageItem(_:)`.

**`movePlayerToward`** — replaced entity parameter and inline path-finding with resolver dispatch:

```swift
// Before
private func movePlayerToward(targetEntity: Entity, within range: Int, onArrival: @escaping () -> Void) {
    let startPosition = playerEntity.gridPosition
    let endPosition = targetEntity.gridPosition
    let path = pathfinder.findPath(from: startPosition, to: endPosition, within: range)
    guard !path.isEmpty else { return }
    if path == [startPosition] {
        onArrival()
    } else {
        let lockOnComponent = LockOnComponent(targetEntity: targetEntity, attackRange: Float(range)) {
            onArrival()
        }
        playerEntity.components.set(lockOnComponent)
        gameSession?.requestMove(to: path.last ?? endPosition)
    }
}

// After
private func movePlayerToward(targetPosition: SIMD2<Int>, within range: Int, onArrival: @escaping () -> Void) {
    let startPosition = playerEntity.gridPosition
    switch interactionResolver.decideMovement(from: startPosition, toward: targetPosition, within: range) {
    case .alreadyInRange:
        onArrival()
    case .moveTo(let destination):
        let lockOnComponent = LockOnComponent(attackRange: Float(range)) {
            onArrival()
        }
        playerEntity.components.set(lockOnComponent)
        gameSession?.requestMove(to: destination)
    case .noPath:
        break
    }
}
```

The start position is still read from `playerEntity.gridPosition` (the interpolated walking position). The target position now comes from `MapSceneState` via the state-based engage methods.

**Tap gestures and raycast** — monster-hit paths now look up the state object by ID before engaging:

```swift
// Before
case .monster:
    engageMonster(targetEntity: hitEntity)

// After
case .monster:
    if let target = state.objects[mapObject.objectID] {
        engageMonster(target)
    }
```

Item tap gesture and raycast item-hit path call `gameSession?.pickUpItem` directly (unchanged — they never went through `engageItem`).

### What did not change

- **`LockOnSystem`** — still fires `action()` when `WalkingComponent` is removed; entity walking still drives the visual follow
- **`onMovementValueChanged`** — still reads `playerEntity.gridPosition` and `WalkingComponent.path` for thumbstick position; that extraction is out of Phase 4 scope
- **Raycast item pickup** — still calls `gameSession?.pickUpItem` directly (no pathfinding); only the nearest-item button path goes through `engageItem`
- **Rendering behavior** — identical to before

### Known temporary state

- `movePlayerToward` still reads `startPosition` from `playerEntity.gridPosition`. The player position will be moved to `state.player.gridPosition` when walking interpolation state is also tracked in the runtime layer (a later phase).
- `LockOnComponent` is still a RealityKit `Component`. It will be moved into the RealityKit backend in Phase 8.

---

## Phase 5 — Extract Overlay and Projector Interfaces

**Completed:** 2026-03-20
**Branch:** `feature/mapview-rendering-refactor`

### What was done

Removed the HUD dependency on `ARView.project` and `RealityKit` from the UI layer. The runtime now owns an overlay snapshot that records which objects need gauges and their HP/SP values. A `MapProjector` protocol abstracts world-to-screen projection so `MapView` never needs to import `RealityKit`. The ARView backend implements the projector and synchronises world positions from the entity tree every render frame.

### New files

#### `Engine/Runtime/MapOverlayAnchor.swift`

```swift
public struct MapOverlayAnchor: Identifiable, Sendable {
    public let id: UInt32
    public var hp: Int
    public var maxHp: Int
    public var sp: Int?
    public var maxSp: Int?
    public var objectType: MapObjectType
    public var gaugePosition: SIMD3<Float>?   // nil until the first frame sync
}
```

Holds all the data needed to render one HP/SP gauge. `gaugePosition` is optional: it starts `nil` and is populated by the per-frame sync in the backend. `MapView.updateOverlay` skips any anchor whose `gaugePosition` is still `nil`, preventing a flash at world-origin before the entity is found.

#### `Engine/Runtime/MapOverlaySnapshot.swift`

```swift
@MainActor
@Observable
public final class MapOverlaySnapshot {
    public var anchors: [UInt32: MapOverlayAnchor] = [:]
}
```

`@Observable` so SwiftUI can react to changes without polling. Lives on `MapSceneState` as `public let overlaySnapshot = MapOverlaySnapshot()`.

#### `Client/Rendering/MapProjector.swift`

```swift
@MainActor
public protocol MapProjector: AnyObject {
    func project(_ worldPosition: SIMD3<Float>) -> CGPoint?
}
```

The only backend-facing API that `MapView` calls. `MapView` never imports `RealityKit` to obtain a screen point; it asks a projector instead.

### Modified files

#### `Engine/Runtime/MapSceneState.swift`

Added `public let overlaySnapshot = MapOverlaySnapshot()`.

#### `Engine/Scene/MapScene.swift`

**Anchor lifecycle** — anchors are created and removed to mirror the entity lifecycle:

| Event | Action |
|---|---|
| `init()` | Insert player anchor with HP/SP from `CharacterInfo` |
| `onMapObjectSpawned` (`.monster`) | Insert monster anchor |
| `onMapObjectMoved` (first-seen, `.monster`) | Insert monster anchor in the synthesised-state else branch — without this, monsters first observed via `packet_unit_walking` would never get a gauge |
| `onMapObjectVanished` | Remove anchor |
| `onReceivePacket(PACKET_ZC_PAR_CHANGE)` | Update player anchor HP/SP in-place |
| `onReceivePacket(PACKET_ZC_HP_INFO)` | Update player or monster anchor HP in-place |
| `onMapObjectStateChanged` | Remove anchor on hide (`.cloak`), restore from current state on unhide |

The visibility handler also correctly distinguishes player from monster: the player is not in `state.objects`, so the restore path checks `state.player.id == objectID` before falling through to the `state.objects` monster path. `state.player.isVisible` is now also written here, which was previously missed.

Anchor `gaugePosition` is intentionally left as the default `nil` on creation. The per-frame sync in the backend fills it on the first render tick after the entity appears in the scene. There are no calls to `position(for: gridPosition)` in the overlay path — static grid positions were tried and removed because `WalkingSystem` interpolates entity positions every frame, making any grid-derived value stale the moment a walk begins.

#### `Client/Rendering/MapRenderHost.swift`

- Removed `import RealityKit`
- Changed `var onSceneUpdate: (ARView) -> Void` → `var onSceneUpdate: (any MapProjector) -> Void`

#### `Client/Views/MapSceneARView.swift`

Added `ARViewProjector` — a private `@MainActor` class defined once under `#if os(iOS) || os(macOS)`:

```swift
private final class ARViewProjector: MapProjector {
    func project(_ worldPosition: SIMD3<Float>) -> CGPoint? {
        guard var screenPoint = arView.project(worldPosition) else { return nil }
        #if os(macOS)
        screenPoint.y = arView.bounds.height - screenPoint.y
        #endif
        return screenPoint
    }
}
```

The macOS Y-flip that previously lived in `MapView.updateOverlay` is now encapsulated here where it belongs.

Both `MapSceneARViewController` implementations (`UIViewController` on iOS, `NSViewController` on macOS) now:
- Hold `private var arViewProjector: ARViewProjector!`, created in `viewDidLoad` after `arView`
- Call a shared `syncOverlayAnchorPositions(in:for:)` free function before `onSceneUpdate` in the `SceneEvents.Update` subscription

`syncOverlayAnchorPositions` is the key piece that makes per-frame position tracking work:

```swift
@MainActor
private func syncOverlayAnchorPositions(in arView: ARView, for mapScene: MapScene) {
    let query = EntityQuery(where: .has(HealthPointsComponent.self))
    for entity in arView.scene.performQuery(query) {
        guard let mapObject = entity.components[MapObjectComponent.self]?.mapObject,
              mapScene.state.overlaySnapshot.anchors[mapObject.objectID] != nil else {
            continue
        }
        let worldPosition = entity.position(relativeTo: nil)
        mapScene.state.overlaySnapshot.anchors[mapObject.objectID]?.gaugePosition = worldPosition + [0, -0.8, 0]
    }
}
```

It queries the same set of entities (`HealthPointsComponent`) and uses the same offset (`-0.8` in Y) as the old `updateOverlay(arView:)`. Running before `onSceneUpdate` means positions are current by the time the projector runs. The `guard` that checks `anchors[objectID] != nil` means disabled/cloaked entities whose anchors were removed do not get positions written back in — the anchor removal in `onMapObjectStateChanged` is the authoritative hide signal.

#### `Client/Views/MapView.swift`

- Removed `import RealityKit`
- Deleted `updateOverlay(arView:)` — the entity-query, `ARView.project`, and macOS Y-flip logic are all gone from this file
- Added `updateOverlay(projector:)`:

```swift
private func updateOverlay(projector: any MapProjector) {
    var gauges: [UInt32: MapSceneOverlay.Gauge] = [:]
    for anchor in scene.state.overlaySnapshot.anchors.values {
        guard let gaugePosition = anchor.gaugePosition,
              let screenPoint = projector.project(gaugePosition) else {
            continue
        }
        gauges[anchor.id] = MapSceneOverlay.Gauge(
            objectID: anchor.id,
            hp: anchor.hp,
            maxHp: anchor.maxHp,
            sp: anchor.sp,
            maxSp: anchor.maxSp,
            objectType: anchor.objectType,
            screenPosition: screenPoint
        )
    }
    gameSession.overlay.gauges = gauges
}
```

No `RealityKit` types appear anywhere in this function.

### What did not change

- **`MapSceneOverlay`** — still the screen-space UI model read by `MapSceneOverlayView`; its structure is unchanged
- **`GaugeView`** — unchanged
- **Rendering behavior** — HP/SP bars display identically to before
- **visionOS** — immersive space path is unchanged; overlay is not rendered on visionOS in this phase

### Known temporary state

- `syncOverlayAnchorPositions` reads `HealthPointsComponent` from the entity tree each frame. This is a deliberate transitional coupling: once Phase 8 moves entity ownership fully into the RealityKit backend, this sync will move with it and become an internal backend concern rather than straddling the boundary.
- The `onSceneUpdate` closure type (`(any MapProjector) -> Void`) is still present on `MapRenderHost`. It will be replaced by the backend lifecycle interface in Phase 7.

---

## Phase 6 — Introduce a Shared World Asset Layer

**Completed:** 2026-03-21
**Branch:** `feature/mapview-rendering-refactor`

### What was done

Introduced a new shared scene-asset package and moved world extraction out of the RealityKit world builder. `WorldEntity` no longer reaches into `WorldResource`, `RSM`, and texture files directly to build the scene graph. Instead, it asks a new `MapWorldAssetLoader` to produce a backend-agnostic `MapWorldAsset`, then rebuilds the existing RealityKit scene from that asset.

This is the first step that makes the static map world consumable by more than one backend. No user-visible rendering behavior changed: the current RealityKit path still renders the same ground, water, and model content as before.

### New files

#### `Packages/RagnarokSceneAssets/Package.swift`

Creates the new `RagnarokSceneAssets` Swift package. It depends on:

- `ImageRendering`
- `RagnarokFileFormats`
- `RagnarokRenderers`
- `RagnarokResources`

There is intentionally no `RealityKit` dependency here. This package is the engine-agnostic boundary.

#### `Packages/RagnarokSceneAssets/Sources/RagnarokSceneAssets/MapWorldAsset.swift`

```swift
public struct MapWorldAsset {
    public var lighting: WorldLighting
    public var ground: GroundRenderAsset
    public var water: WaterRenderAsset
    public var models: [ModelRenderAsset]
}
```

Single payload representing everything the backend needs for the static world: lighting, ground, water, and model prototypes/instances.

#### `Packages/RagnarokSceneAssets/Sources/RagnarokSceneAssets/GroundRenderAsset.swift`

```swift
public struct GroundRenderAsset {
    public var ground: Ground
    public var textureImages: [String : CGImage]
}
```

Carries the compiled `Ground` mesh plus the decoded source texture images referenced by `gnd.textures`.

#### `Packages/RagnarokSceneAssets/Sources/RagnarokSceneAssets/WaterRenderAsset.swift`

```swift
public struct WaterRenderAsset {
    public var water: Water
    public var textureImage: CGImage?
}
```

Carries the compiled `Water` mesh plus the stitched 32-frame water texture strip. The strip width is always `32 * 128` pixels even if some frames are missing, matching the legacy `waterTexture()` layout so the RealityKit UV animation still lines up.

#### `Packages/RagnarokSceneAssets/Sources/RagnarokSceneAssets/ModelRenderAsset.swift`

```swift
public struct ModelRenderAsset {
    public struct Instance {
        public var position: SIMD3<Float>
        public var rotation: SIMD3<Float>
        public var scale: SIMD3<Float>
    }

    public var name: String
    public var model: Model
    public var textureImages: [String : CGImage]
    public var instances: [Instance]
}
```

Represents one prototype model plus all of its placements in the world. The prototype mesh is compiled once from `RSM`; instance transforms stay separate so backends can choose whether to clone, instance-draw, or otherwise batch them later.

`position` already includes the `+gnd.width/+gnd.height` world-space offset that previously lived in `WorldEntity`, so backends do not need to rediscover that conversion.

#### `Packages/RagnarokSceneAssets/Sources/RagnarokSceneAssets/MapWorldAssetLoader.swift`

Loads `MapWorldAsset` from `GAT`, `GND`, `RSW`, and `ResourceManager`.

Important implementation details:

- Preserves model-name order based on first appearance in `rsw.models`
- Loads model files and texture file data with task groups, but decodes them into `RSM` / `CGImage` on the parent task
- Uses `Data` as the task-group payload instead of `CGImage` to avoid strict-concurrency sendability problems in the loader
- Updates `Progress` through `@MainActor` helper methods rather than mutating it from child tasks
- Mirrors the old loading-progress semantics: ground textures + model textures are counted; water texture assembly is not

### Modified files

#### `Packages/RagnarokReality/Sources/RagnarokReality/WorldEntity.swift`

- Added `import RagnarokSceneAssets`
- Replaced the old inline world-loading path with `MapWorldAssetLoader.load(...)`
- Ground creation now uses `worldAsset.ground`
- Water creation now uses `worldAsset.water`
- Model prototype creation now uses `ModelRenderAsset`
- Model instance placement now reads `modelAsset.instances` instead of `world.rsw.models`

The prototype-model stage is now **sequential**, not task-group-based. This was a deliberate strict-concurrency fix: `ModelRenderAsset` carries `CGImage`, which is not a clean `Sendable` payload for child tasks. Rather than add unsafe annotations, prototype entity creation stays sequential until the asset representation changes.

#### `Packages/RagnarokReality/Sources/RagnarokReality/ModelEntity.swift`

Added:

```swift
public convenience init(
    from asset: ModelRenderAsset,
    lighting: WorldLighting
) async throws
```

This converts the asset’s `CGImage` dictionary into RealityKit `TextureResource`s, then reuses the existing `init(from model:lighting:textures:)` path. The backend-specific texture conversion now happens here where it belongs, not inside the shared asset loader.

#### `Packages/RagnarokReality/Sources/RagnarokReality/WaterEntity.swift`

Added:

```swift
public convenience init(from asset: WaterRenderAsset) async throws
```

This consumes the stitched water texture strip from the asset layer and keeps the same RealityKit material setup and `SampledAnimation` UV scrolling behavior as before.

The older `init(from water:resourceManager:)` overload was left in place because it is still used by other non-refactor call sites and previews.

#### `Packages/RagnarokReality/Package.swift`

Added `RagnarokSceneAssets` as a package and target dependency.

#### `Packages/RagnarokGame/Package.swift`

Added `RagnarokSceneAssets` as a package and target dependency.

`RagnarokGame` does not import it yet, but wiring it now avoids another manifest-only phase when the backend interface starts moving into the game package.

### What did not change

- **`WorldResource`** — still lives in `RagnarokReality`; Phase 6 only changes what happens *after* the world has been loaded from disk/GRF
- **`GroundEntity`** — still builds the final atlas textures internally from source `CGImage`s; the asset layer stops before backend-specific `TextureResource` creation
- **`MapScene.load(progress:)`** — still calls `Entity(from: world, resourceManager: progress:)`; the call site did not change
- **`RSMFilePreviewView` and other preview helpers** — still use the older RealityKit model-loading helpers where appropriate
- **Rendering behavior** — ground, water animation, and placed world models render identically to before

### Known temporary state

- `MapWorldAsset` is **not** `Sendable`. That is intentional for now because it contains `CGImage`s. If a later phase wants to parallelise more backend construction work, the asset package will need a different image payload or a more isolated conversion boundary.
- `GroundRenderAsset` stores source ground textures instead of a prebuilt atlas image. This keeps the asset package closer to the renderer inputs, but it means atlas assembly is still duplicated knowledge in backend code.
- `WorldResource` and `ModelResource` still exist in `RagnarokReality`. Phase 6 introduces the shared asset layer without yet moving all legacy resource types out of that package.
- `ResourceManager+Texture.swift` remains in `RagnarokReality` for legacy call sites. Phase 6 does not remove that file even though `WorldEntity` no longer relies on it.

### Next phase

**Phase 7 — Create the RealityKit Backend Shell.**
Define the shared backend lifecycle interface and make `MapRenderHost` instantiate a backend implementation rather than directly choosing concrete render views.

---

## Phase 7 — Create the RealityKit Backend Shell

**Completed:** 2026-03-21
**Branch:** `feature/mapview-rendering-refactor`

### What was done

Formalized the RealityKit rendering path as the first proper backend implementation behind a shared `MapRenderBackend` protocol. The per-frame overlay callback (`onSceneUpdate: (any MapProjector) -> Void`) that previously threaded a projector from `MapSceneARView` through `MapRenderHost` to `MapView` is eliminated. Overlay sync and projection are now unified inside the backend. No rendering behavior changed.

### New files

#### `Client/Rendering/MapRenderBackend.swift`

```swift
public enum MapHitTestResult: Sendable {
    case mapObject(objectID: UInt32)
    case item(objectID: UInt32)
    case ground(position: SIMD2<Int>)
}

@MainActor
public protocol MapRenderBackend: AnyObject {
    var projector: (any MapProjector)? { get }

    func attach(scene: MapScene)
    func detach()

    func applySnapshot(_ state: MapSceneState)

    func hitTest(at screenPoint: CGPoint) -> MapHitTestResult?
}
```

Defines the backend lifecycle. `attach` and `detach` manage the scene reference. `applySnapshot` is the entry point for pushing runtime state into the backend (no-op in Phase 7 — `MapScene` still updates the entity tree directly). `hitTest` formalizes screen-point hit testing (returns `nil` in Phase 7 — gesture handlers still drive hit testing directly). `projector` provides world-to-screen projection on iOS/macOS; returns `nil` on visionOS where screen projection is not applicable.

`MapHitTestResult` is the shared hit-test return type. Cases follow the unified interaction priority from the implementation decisions: map object → item → ground.

#### `Client/Rendering/RealityBackend/RealityKitMapBackend.swift`

```swift
@MainActor
final class RealityKitMapBackend: MapRenderBackend {
    private(set) var scene: MapScene?
    var overlay: MapSceneOverlay?

    #if os(iOS) || os(macOS)
    private var realityMapProjector: RealityMapProjector?
    private var realityMapHitTester: RealityMapHitTester?
    #endif

    var projector: (any MapProjector)? { ... }

    func attach(scene: MapScene) { ... }
    func detach() { ... }
    func applySnapshot(_ state: MapSceneState) { /* no-op */ }
    func hitTest(at screenPoint: CGPoint) -> MapHitTestResult? { ... }

    #if os(iOS) || os(macOS)
    func configure(arView: ARView) { ... }
    func syncAndProjectOverlay() { ... }
    #endif
}
```

First `MapRenderBackend` conformer. Platform-conditional: on iOS/macOS it owns the projector, hit tester, and per-frame overlay sync. On visionOS it is a no-op shell (no projector, no overlay sync).

`configure(arView:)` is called by `MapSceneARViewController.viewDidLoad` after the `ARView` is created. It creates the `RealityMapProjector` and `RealityMapHitTester` from the live `ARView`.

`syncAndProjectOverlay()` is the key method. It replaces the old two-step flow that was split across files:
1. **Before:** `syncOverlayAnchorPositions` (free function in `MapSceneARView.swift`) synced entity world positions to overlay anchors, then `onSceneUpdate(projector)` called `MapView.updateOverlay(projector:)` to project anchors to screen positions and write `gameSession.overlay.gauges`.
2. **After:** `syncAndProjectOverlay()` does both steps in one call. It queries entities with `HealthPointsComponent`, syncs their world positions to `overlaySnapshot.anchors`, projects them via `RealityMapProjector`, and writes the result directly to `overlay.gauges`.

This eliminates the `onSceneUpdate: (any MapProjector) -> Void` callback that Phase 5 noted as temporary state on `MapRenderHost`.

#### `Client/Rendering/RealityBackend/RealityMapProjector.swift`

```swift
#if os(iOS) || os(macOS)

@MainActor
final class RealityMapProjector: MapProjector {
    let arView: ARView

    func project(_ worldPosition: SIMD3<Float>) -> CGPoint? {
        guard var screenPoint = arView.project(worldPosition) else { return nil }
        #if os(macOS)
        screenPoint.y = arView.bounds.height - screenPoint.y
        #endif
        return screenPoint
    }
}

#endif
```

Extracted from the private `ARViewProjector` that previously lived in `MapSceneARView.swift`. Same logic including the macOS Y-flip. Now owned by the backend and accessible through `backend.projector`.

#### `Client/Rendering/RealityBackend/RealityMapHitTester.swift`

```swift
#if os(iOS) || os(macOS)

@MainActor
final class RealityMapHitTester {
    private weak var arView: ARView?
    private weak var scene: MapScene?

    func hitTest(at screenPoint: CGPoint) -> MapHitTestResult? {
        nil
    }
}

#endif
```

Shell for the shared hit-test interface. Returns `nil` in Phase 7. Tap and click gestures still flow through `MapSceneARViewController`'s gesture handlers → `MapScene.raycast()`. Will be wired in Phase 8 when entity ownership moves fully into the backend.

#### `Client/Rendering/RealityBackend/MapRealityView.swift`

```swift
public struct MapRealityView: View {
    var scene: MapScene
    var overlay: MapSceneOverlay?

    @State private var backend = RealityKitMapBackend()

    public var body: some View {
        #if os(visionOS)
        MapSceneRealityView(scene: scene)
            .onAppear { backend.attach(scene: scene) }
            .onDisappear { backend.detach() }
        #else
        MapSceneARView(scene: scene, overlay: overlay, backend: backend)
            .onDisappear { backend.detach() }
        #endif
    }

    public init(scene: MapScene) { ... }          // public: used by visionOSApp
    init(scene: MapScene, overlay: MapSceneOverlay?) { ... }  // internal: used by MapRenderHost
}
```

Unified view wrapping both platform-specific surfaces. Owns the backend lifecycle via `@State`. On visionOS it wraps `MapSceneRealityView`; on iOS/macOS it wraps `MapSceneARView` and passes the backend.

Two initializers: the `public init(scene:)` is used by `visionOSApp.swift` (the overlay parameter is internal to the module). The internal `init(scene:overlay:)` is used by `MapRenderHost` on iOS/macOS.

On iOS/macOS, the backend is attached in `MapSceneARViewController.init` (before `viewDidLoad`), then configured with the `ARView` in `viewDidLoad`. On visionOS, the backend is attached in `.onAppear` (no ARView configuration needed).

### Modified files

#### `Client/Rendering/MapRenderHost.swift`

- Removed `#if !os(visionOS) var onSceneUpdate: (any MapProjector) -> Void` — the per-frame callback is gone
- Added `var overlay: MapSceneOverlay?`
- Both `.metal` and `.realityKit` cases route to the same `renderSurface` computed property
- `renderSurface` returns `Text("Game")` placeholder on visionOS, `MapRealityView(scene:overlay:)` on iOS/macOS

The visionOS placeholder is intentional and critical: `MapView` opens an `ImmersiveSpace` on visionOS, and `visionOSApp` renders `MapRealityView` there. A RealityKit entity can only belong to one host at a time. If `MapRenderHost` also rendered `MapRealityView` on visionOS, both the window and the immersive space would call `content.add(scene.rootEntity)` and one would steal the entity from the other, causing the map to disappear or flicker.

#### `Client/Views/MapSceneARView.swift`

- Removed `ARViewProjector` class (extracted to `RealityMapProjector`)
- Removed `syncOverlayAnchorPositions` free function (moved into `RealityKitMapBackend.syncAndProjectOverlay()`)
- Both iOS and macOS `MapSceneARView` structs: replaced `onSceneUpdate: (any MapProjector) -> Void` with `overlay: MapSceneOverlay?` and `backend: RealityKitMapBackend`
- Both `MapSceneARViewController` implementations:
  - Removed `onSceneUpdate` and `arViewProjector` stored properties
  - Added `backend: RealityKitMapBackend` stored property
  - `init`: calls `backend.attach(scene:)` and sets `backend.overlay`
  - `viewDidLoad`: calls `backend.configure(arView:)` instead of creating `ARViewProjector`
  - Per-frame subscription: calls `backend.syncAndProjectOverlay()` instead of `syncOverlayAnchorPositions` + `onSceneUpdate`
- Gesture handlers and raycast logic are unchanged — still drive hit testing directly

#### `Client/Views/MapView.swift`

- Removed `import RealityKit` (already removed in Phase 5, confirmed still absent)
- Removed `updateOverlay(projector:)` method entirely — the backend handles overlay sync and projection internally
- `MapRenderHost` is now created without a callback:
  - visionOS: `MapRenderHost(scene: scene, configuration: renderConfiguration)`
  - iOS/macOS: `MapRenderHost(scene: scene, configuration: renderConfiguration, overlay: gameSession.overlay)`

#### `RagnarokOffline/App/visionOSApp.swift`

- `ImmersiveSpace` body: replaced `MapSceneRealityView(scene: mapScene)` with `MapRealityView(scene: mapScene)`
- Uses the public `init(scene:)` — no overlay parameter needed on visionOS

### Phase 8

Moved the remaining RealityKit ownership out of `MapScene` and into `RealityKitMapBackend`. `MapScene` is now a gameplay/runtime coordinator: it still owns runtime state (`MapSceneState` and `MapCameraState`) and interaction decisions, but it no longer owns the RealityKit entity tree, camera entity, tile selector entity, world loading, hit testing, or platform gesture wiring.

#### `Engine/Scene/MapScene.swift`

- Removed direct `RealityKit`, `SwiftUI`, `SpatialTapGesture`, and entity-tree ownership from `MapScene`
- `load(progress:)` now delegates world/entity setup to `realityKitBackend.load(progress:)`
- `unload()` now delegates to the backend and detaches the scene/backend relationship
- Packet-driven entity mutations (`spawn`, `move`, `stop`, `vanish`, visibility changes, skill/action animation hooks, item spawn/remove, HP/SP updates) now update runtime state first, then delegate the visual/entity work to backend methods
- `handleInteraction(_:)` remains the gameplay decision point for `MapHitTestResult`
- Thumbstick movement no longer reads `state.player.gridPosition` blindly when the player is already moving; it asks the backend for the current movement origin (`WalkingComponent.path[1]` or the entity grid position) so follow-up move requests start from the same logical point the old entity-driven code used
- Removed the temporary runtime-side `pendingArrivalAction` shortcut. Arrival-triggered follow-up actions now go back through backend-owned `LockOnComponent` / `LockOnSystem`, so the action fires when the visible walk actually completes rather than when the server confirms the move packet

#### `Client/Rendering/RealityBackend/RealityKitMapBackend.swift`

- Expanded from a shell into the owner of:
  - `rootEntity`
  - `worldCameraEntity`
  - world/skybox/audio construction
  - player/object/item entity creation and updates
  - tile entity creation on visionOS
  - tile selection rendering
  - RealityKit hit testing
  - overlay sync + projection
  - platform-specific targeted gestures on visionOS
- `attach(scene:)` now also prepares a reusable `Pathfinder` for the scene's `mapGrid`; walk updates no longer instantiate a fresh `Pathfinder` per movement update
- `hitTest(at:)` is now live on iOS/macOS via `RealityMapHitTester`
- Added `schedulePlayerArrivalAction(...)` so arrival-triggered gameplay actions stay tied to the entity walking lifecycle
- Restored the old non-monster `performSkill` TODO context before `castSkill(direction:)`:
  - `// TODO: Show dialog with skill name`
- Removed the redundant `entityCache.addObjectEntity(...)` write in `load()` after the player entity was already cached by `entityCache.objectEntity(for:)`

#### New backend helpers

- `RealityEntityCache.swift`
  - Replaces the old runtime-owned sprite cache responsibilities
  - Owns object/item entity caching plus non-player template cloning
- `RealitySpriteNodeFactory.swift`
  - Centralizes map object and map item entity construction from `ResourceManager`
- `RealityTileSelectionRenderer.swift`
  - Owns the selector entity, selector texture preparation, and selected-tile mesh updates

#### `Client/Views/MapSceneARView.swift`

- The controller remains the input bridge, but the data flow is now:
  - controller receives platform input
  - backend performs hit testing
  - controller passes `MapHitTestResult` directly to `MapScene.handleInteraction(_:)`
- This intentionally removes the awkward temporary flow where the controller called `backend.handleInteraction(...)` only for the backend to forward back into `MapScene`
- Per-frame `SceneEvents.Update` still drive `backend.syncAndProjectOverlay()`

#### `Client/Views/MapSceneRealityView.swift`

- Now renders `backend.rootEntity` rather than a `MapScene`-owned root entity
- visionOS targeted gestures now live in the backend and forward `MapHitTestResult` semantics back to `MapScene`

### What did not change

- **`MapScene` still owns gameplay/runtime state** — `MapSceneState`, `MapCameraState`, and interaction decisions remain outside the backend
- **`MapProjector` protocol** — unchanged; `RealityMapProjector` still conforms to it
- **`MapRenderingSurface` protocol** — unchanged marker protocol from Phase 1
- **`MapRenderEngine` / `MapRenderConfiguration`** — unchanged
- **`Package.swift`** — no new targets or dependencies; the new backend helpers still live under the existing `RagnarokGame` target
- **`MapRenderHost` engine routing** — iOS/macOS still route both `.metal` and `.realityKit` through the RealityKit path until Phase 9 introduces `MapMetalView`

### Known temporary state

- `applySnapshot(_:)` is no longer a no-op, but it is still narrow in scope: it currently syncs camera state and selected-tile rendering rather than performing a full diff-based scene sync from `MapSceneState`
- `MapScene` still knows about the concrete `RealityKitMapBackend` type. That coupling is acceptable in the current single-backend phase, but it will need another abstraction pass before Metal becomes the primary iOS/macOS runtime
- `MapScene` still imports `RagnarokReality` for `WorldResource`; Phase 8 removed direct `RealityKit` ownership from the runtime, but the package boundary cleanup is still pending
- `MapRealityView` no longer owns the backend as `@State`; the backend now lives with the scene lifetime instead. This is fine for the current single-scene RealityKit path, but should be revisited when multiple backend implementations coexist
- The `RealityBackend/` subdirectory still lives inside the `RagnarokGame` target. The eventual plan remains to split it into a separate target once the shared core/runtime surface is extracted

---

## Phase 9 — Create the Metal Backend Shell

**Completed:** 2026-03-22
**Branch:** `feature/mapview-rendering-refactor`

### What was done

Stood up the Metal backend lifecycle and wired `MapRenderHost` to route the `.metal` engine selection to a real `MapMetalView` on iOS and macOS. The view shows a blank (cleared) scene at this stage — no world geometry is connected yet. The RealityKit path is unaffected.

### New files

All new files live under `Client/Rendering/MetalBackend/`.

#### `MetalMapProjector.swift`

```swift
@MainActor
final class MetalMapProjector: MapProjector {
    func project(_ worldPosition: SIMD3<Float>) -> CGPoint? {
        nil
    }
}
```

Shell `MapProjector` conformer. Always returns `nil`. Phase 10 will drive this from the Metal view-projection matrix so HP/SP gauges align to screen space.

#### `MetalMapHitTester.swift`

```swift
@MainActor
final class MetalMapHitTester {
    func hitTest(at screenPoint: CGPoint) -> MapHitTestResult? {
        nil
    }
}
```

Shell hit tester. Always returns `nil`. Phase 11 will connect depth-buffer raycasting and object selection.

#### `MapRuntimeRenderer.swift`

```swift
@MainActor
final class MapRuntimeRenderer: Renderer {
    let device: any MTLDevice

    init() { ... }

    func render(
        atTime time: CFTimeInterval,
        viewport: CGRect,
        commandBuffer: any MTLCommandBuffer,
        renderPassDescriptor: MTLRenderPassDescriptor
    ) {
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        encoder.endEncoding()
    }
}
```

Conforms to `Renderer` from `RagnarokRenderers`. Phase 9 body encodes an empty render pass. Phase 10 will connect ground, water, and model rendering through this type by wiring `MapWorldAsset` into render passes here.

#### `MetalMapBackend.swift`

```swift
@MainActor
final class MetalMapBackend: MapRenderBackend {
    private(set) weak var scene: MapScene?
    let renderer: MapRuntimeRenderer

    var projector: (any MapProjector)? { metalMapProjector }

    func attach(scene: MapScene) { self.scene = scene }
    func detach() { scene = nil }
    func applySnapshot(_ state: MapSceneState) { }
    func hitTest(at screenPoint: CGPoint) -> MapHitTestResult? { ... }
}
```

`MapRenderBackend` conformer for the Metal path. Owns `MapRuntimeRenderer`, `MetalMapProjector`, and `MetalMapHitTester`. `applySnapshot` is a no-op in Phase 9 — all packet-driven mutations still route exclusively through `scene.realityKitBackend`. Phase 10 will begin consuming the snapshot to drive world rendering.

The backend is owned by `MapMetalView` via `@State` (the "expensive cache" pattern — it holds `MTLDevice` and a command queue, which are costly to recreate). It is not `@Observable` because `MapMetalView` does not need to re-render in response to backend state changes.

#### `MapMetalView.swift`

```swift
struct MapMetalView: View {
    var scene: MapScene
    var overlay: MapSceneOverlay?

    @State private var backend = MetalMapBackend()

    var body: some View {
        MapMetalViewContainer(renderer: backend.renderer)
            .onAppear { backend.attach(scene: scene) }
            .onDisappear { backend.detach() }
    }
}
```

SwiftUI host for the Metal backend. Contains two private platform-specific types (`MapMetalViewContainer` and `MapMTKHostView`) that are implementation details of this file, not exported types.

`MapMTKHostView` extends `UIView`/`NSView`, inheriting `@MainActor` isolation. On iOS, `MTKView` drives the delegate via `CADisplayLink`, which fires on the main thread — so `draw(in:)` is always called within `@MainActor` isolation. The stored `MapRuntimeRenderer` is `@MainActor` so the call to `renderer.render(...)` in `draw(in:)` is safe without any bridging.

### Modified files

#### `Packages/RagnarokGame/Package.swift`

Added `RagnarokRenderers` as a package and target dependency. Required so `MapRuntimeRenderer` can conform to the `Renderer` protocol.

#### `Client/Rendering/MapRenderHost.swift`

Replaced the single `renderSurface` computed property (which was routing both `.metal` and `.realityKit` to `MapRealityView`) with a direct `switch` in `body`:

```swift
// Before
var body: some View {
    switch configuration.engine {
    case .metal:    renderSurface
    case .realityKit: renderSurface
    }
}

private var renderSurface: some View { ... /* always MapRealityView */ }

// After
var body: some View {
    #if os(visionOS)
    Text("Game").frame(maxWidth: .infinity, maxHeight: .infinity)
    #else
    switch configuration.engine {
    case .metal:      MapMetalView(scene: scene, overlay: overlay)
    case .realityKit: MapRealityView(scene: scene, overlay: overlay)
    }
    #endif
}
```

The visionOS placeholder is now expressed once at the top level rather than inside each case, which makes the intent clear: visionOS never uses `MapRenderHost` for real rendering — it opens an `ImmersiveSpace` through `MapView` instead.

### What did not change

- **All packet-driven rendering** — still routes through `scene.realityKitBackend`. The Metal backend receives no scene events in Phase 9.
- **`MapScene`** — unchanged.
- **`RealityKitMapBackend`** — unchanged.
- **`RagnarokOffline/Core/MetalView.swift`** — unchanged. It remains in the app target for non-game usages (`EffectViewer`, `STRFilePreviewView`).
- **visionOS immersive space** — unchanged.

### Known temporary state

- `MapMetalView` renders a blank scene. Phase 10 will connect `MapWorldAsset` to `MapRuntimeRenderer`.
- `MetalMapProjector.project` always returns `nil`. HP/SP overlay gauges do not appear in Metal mode.
- `MetalMapHitTester.hitTest` always returns `nil`. Tap interaction is not wired in Metal mode.
- `MetalMapBackend` is not stored on `MapScene`. All packet-driven mutations still go exclusively through `scene.realityKitBackend`. This changes in Phase 10 when the backend begins consuming snapshots to drive world rendering.

### Next phase

**Phase 10 — Connect Static World Rendering in Metal.**
Drive ground, water, and static model rendering from `MapWorldAsset` through `MapRuntimeRenderer`. Connect `MapCameraState` to the Metal camera matrix so the scene displays and responds to rotation and zoom.
