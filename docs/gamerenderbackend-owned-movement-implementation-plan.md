# GameRenderBackend-Owned Movement Implementation Plan

## Context

`MapSceneObject` currently carries `movement: MapObjectMovementState?`, and `MapScene` owns movement replanning through `MapObjectMovementPlanner`. That makes movement a shared gameplay/rendering concern: packet handlers update logical object state, compute presentation continuity, and then notify the renderer.

The target design is to move movement and replanning into `GameRenderBackend`.

`MapScene` should keep only logical state:

- object identity, type, stats, status, appearance
- server-confirmed grid position
- high-level presentation action, such as idle, walk, attack, skill, hurt, die

The render backend should own presentation movement:

- active movement timelines
- replanning from existing presentation movement
- current presentation grid/world position
- backend-specific camera target and overlay placement derived from presentation position

## Goals

- Remove `movement` from `MapSceneObject`.
- Remove movement replanning from `MapScene`.
- Add explicit movement commands to `GameRenderBackend`.
- Let both Reality and Metal backends own their active movement state.
- Let `MapScene` ask the backend for the player's current presentation position when it needs an interaction origin.

## Non-Goals

- Do not move all animation presentation state out of `MapSceneObject` in this pass.
- Do not remove `MapSceneObject.presentation`.
- Do not redesign combat text, skill effects, sounds, or item rendering.
- Do not add a snapshot/reconcile fallback.
- Do not make Metal maintain per-object drawable groups; Metal can continue rebuilding drawables from current backend state.

## Target API

Add a movement command model, preferably near the other runtime rendering models:

```swift
struct MapObjectMoveCommand: Sendable {
    var objectID: GameObjectID
    var startPosition: SIMD2<Int>
    var endPosition: SIMD2<Int>
    var speed: Int
    var startedAt: ContinuousClock.Instant
}
```

Extend `GameRenderBackend`:

```swift
@MainActor
protocol GameRenderBackend: AnyObject {
    func attach(scene: MapScene)
    func detach()

    func load(progress: Progress) async
    func unload()

    func updateCamera(_ cameraState: MapCameraState)

    func addObject(_ object: MapSceneObject)
    func updateObject(_ object: MapSceneObject)
    func moveObject(_ command: MapObjectMoveCommand)
    func stopObject(objectID: GameObjectID, at position: SIMD2<Int>)
    func removeObject(objectID: GameObjectID)

    func addItem(_ item: MapSceneItem)
    func removeItem(objectID: GameObjectID)

    func presentationGridPosition(for objectID: GameObjectID) -> SIMD2<Int>?
    func presentationWorldPosition(for objectID: GameObjectID) -> SIMD3<Float>?

    func showSelection(at position: SIMD2<Int>, mapGrid: MapGrid)
    func addCombatText(_ combatText: MapSceneCombatText)
    func addEffect(_ effect: MapSceneEffect)
    func playSound(named soundName: String, on objectID: GameObjectID)
}
```

`presentationWorldPosition(for:)` may already exist as a backend-private helper in both implementations. This refactor promotes the concept to the protocol because `MapScene` no longer owns enough movement state to answer presentation-position questions itself.

## Data Model Changes

### MapSceneObject

Remove:

```swift
public var movement: MapObjectMovementState?
```

Update its initializer by removing the `movement` parameter.

Keep:

- `gridPosition` as the latest logical/server-confirmed destination
- `presentation` as the current high-level animation state

This keeps the first refactor focused: movement interpolation moves to the backend, while action selection can remain in `MapScene`.

### MapSceneState

No movement map should be added to `MapSceneState`.

When an object is removed, the event handler should call `renderBackend.removeObject(objectID:)`; each backend is responsible for clearing any movement state for that object.

## MapScene Changes

### Movement origin

Change `playerMovementOrigin()` to ask the backend:

```swift
private func playerMovementOrigin() -> SIMD2<Int> {
    renderBackend.presentationGridPosition(for: player.objectID) ?? state.player.gridPosition
}
```

This is the key ownership change: `MapScene` no longer derives the player's current position from `state.player.movement`.

### Player movement event

`onPlayerMoved(startPosition:endPosition:)` should:

- compute `now`
- update `state.player.gridPosition = endPosition`
- update `state.player.presentation` to `.walk` using the direction supplied by the backend or by the command result strategy described below
- call `renderBackend.moveObject(command)`

Recommended first implementation:

```swift
let command = MapObjectMoveCommand(
    objectID: player.objectID,
    startPosition: startPosition,
    endPosition: endPosition,
    speed: state.player.speed,
    startedAt: now
)
renderBackend.moveObject(command)
```

If `MapScene` still needs `remainingDuration` for `pendingArrivalAction`, the backend needs to return the planned movement:

```swift
@discardableResult
func moveObject(_ command: MapObjectMoveCommand) -> MapObjectMovementState?
```

That return value is acceptable because the backend still owns movement storage; `MapScene` only uses the returned duration for arrival scheduling.

Alternative: move arrival scheduling into the backend or expose a separate `remainingMovementDuration(for:)`. That is larger and should be deferred unless needed.

### Other object movement event

`onMapObjectMoved(object:startPosition:endPosition:)` should:

- update or create the logical `MapSceneObject`
- if the object is new, call `addObject(_:)`
- call `moveObject(_:)` with the packet start/end/speed

Do not replan in `MapScene`.

### Stop event

`onMapObjectStopped(objectID:position:)` should:

- update the logical object grid position
- update presentation to idle
- call `renderBackend.stopObject(objectID:at:)`

The backend clears its active movement for that object.

### Remove/vanish events

For non-player removal:

- remove from `state.objects`
- remove overlay state
- call `renderBackend.removeObject(objectID:)`

The backend clears both render object state and movement state.

For player death:

- keep the player object
- update presentation to `.die`
- call `renderBackend.updateObject(_:)`
- do not call `removeObject`

## Movement Planning Ownership

Both backends should replan with the same existing helper:

```swift
MapObjectMovementPlanner(pathFinder: scene.pathFinder)
```

The backend should use its current movement state as the `existingMovement` input:

```swift
let movement = planner.replan(
    existingMovement: objectMovements[command.objectID],
    existingSpeed: objectStates[command.objectID]?.speed,
    incomingStartPosition: command.startPosition,
    incomingEndPosition: command.endPosition,
    incomingSpeed: command.speed,
    at: command.startedAt
)
```

Each backend stores:

```swift
private var objectMovements: [GameObjectID : MapObjectMovementState] = [:]
```

If `moveObject(_:)` returns `MapObjectMovementState?`, return the planned movement after storing it.

## Presentation Sampling Changes

`MapObjectPresentationSampler` should no longer read movement from `MapSceneObject`.

Change its API from object-owned movement to explicit movement input:

```swift
func sample(
    for object: MapSceneObject,
    movement: MapObjectMovementState?,
    position: (SIMD2<Int>) -> SIMD3<Float>,
    now: ContinuousClock.Instant
) -> MapObjectPresentationSample
```

The sampler should preserve existing behavior:

- when movement exists, interpolate world position and use movement-derived walking animation as appropriate
- when movement is nil, use `object.gridPosition`
- continue honoring `object.presentation` for non-movement actions

The exact precedence between movement and non-walk actions should match current behavior. In particular, attack, skill, hurt, sit, and die states should not be accidentally overwritten by a stale movement timeline.

## RealityRenderBackend Changes

Reality should maintain active movement state and apply it to entity presentation components.

Add:

```swift
private var objectStates: [GameObjectID : MapSceneObject] = [:]
private var objectMovements: [GameObjectID : MapObjectMovementState] = [:]
```

If Reality can rely on components/cache for object state, `objectStates` can be omitted, but having it match Metal makes movement planning and position queries simpler.

### Add/update object

`addObject(_:)` and `updateObject(_:)` should store `objectStates[object.objectID] = object`, then upsert the Reality entity.

When updating the presentation component, pass the active backend movement:

```swift
let movement = objectMovements[object.objectID]
let timeline = movement.map {
    MapObjectMovementTimeline(movement: $0, position: { scene.mapGrid.worldPosition(for: $0) })
}
```

If no initializer exists for movement directly, add one or adapt `MapObjectMovementTimeline` so it no longer requires movement to be stored on `MapSceneObject`.

### Move object

`moveObject(_:)` should:

- guard that the scene exists
- look up the current logical object
- replan using backend-owned `objectMovements`
- store the planned movement
- update the object's Reality entity presentation component
- refresh visionOS tile entities when `command.objectID == scene.state.playerID`
- return the planned movement if the protocol chooses the returning form

### Stop object

`stopObject(objectID:at:)` should:

- remove `objectMovements[objectID]`
- update the entity/component grid position to `position`
- if this is the player, refresh visionOS tile entities around `position`

### Remove object

`removeObject(objectID:)` should remove:

- object entity
- `objectStates[objectID]`
- `objectMovements[objectID]`

### Presentation position queries

`presentationWorldPosition(for:)` can continue to use the Reality entity position when available.

`presentationGridPosition(for:)` should:

- sample `objectMovements[objectID]` at `ContinuousClock.now` when present
- otherwise return `objectStates[objectID]?.gridPosition`
- otherwise fall back to a component value if available

## MetalRenderBackend Changes

Metal should store logical objects, movement states, and rebuilt sprite snapshots.

Add:

```swift
private var objectStates: [GameObjectID : MapSceneObject] = [:]
private var objectMovements: [GameObjectID : MapObjectMovementState] = [:]
private var itemStates: [GameObjectID : MapSceneItem] = [:]
```

### SpriteSnapshotBuilder

Change `build` to accept backend-owned movement:

```swift
func build(
    objects: [GameObjectID : MapSceneObject],
    movements: [GameObjectID : MapObjectMovementState],
    items: [GameObjectID : MapSceneItem],
    scene: MapScene
) -> [GameObjectID : SpriteSnapshot]
```

When building an object snapshot:

```swift
let movement = movements[object.objectID]
let sample = sampler.sample(
    for: object,
    movement: movement,
    position: { scene.mapGrid.worldPosition(for: $0) },
    now: now
)
```

### Move object

`moveObject(_:)` should:

- replan with backend-owned `objectMovements`
- store the planned movement
- refresh sprite drawables
- update the camera target if the moved object is the player
- return the planned movement if needed for arrival scheduling

### Stop object

`stopObject(objectID:at:)` should:

- remove active movement
- update `objectStates[objectID]?.gridPosition = position` if present
- refresh sprite drawables
- update the camera target if this is the player

### Remove object

`removeObject(objectID:)` should remove:

- `objectStates[objectID]`
- `objectMovements[objectID]`
- `spriteSnapshots[objectID]`

Then refresh drawables.

### Presentation position queries

`presentationWorldPosition(for:)` should return:

- `spriteSnapshots[objectID]?.worldPosition`
- otherwise a world position derived from `objectStates[objectID]?.gridPosition`

`presentationGridPosition(for:)` should sample `objectMovements[objectID]` when present; otherwise use `objectStates[objectID]?.gridPosition`.

## Arrival Action Handling

`MapScene.onPlayerMoved` currently uses `movement.remainingDuration(at:)` for `pendingArrivalAction`.

There are two practical options:

### Option A: moveObject returns planned movement

```swift
@discardableResult
func moveObject(_ command: MapObjectMoveCommand) -> MapObjectMovementState?
```

`MapScene` uses the returned value only for scheduling. It does not store movement.

This is the smallest change.

### Option B: backend exposes remaining duration

```swift
func remainingMovementDuration(for objectID: GameObjectID, at now: ContinuousClock.Instant) -> Duration?
```

This keeps the movement command fire-and-forget, but adds another query API.

Recommended initial choice: Option A.

## Implementation Phases

### Phase 1: Add movement command API

- add `MapObjectMoveCommand`
- extend `GameRenderBackend`
- add temporary backend method implementations that delegate to existing update paths
- build `Packages/RagnarokGame`

Validation:

```bash
swift build --package-path Packages/RagnarokGame
```

### Phase 2: Remove movement from MapSceneObject

- remove `movement` property and initializer parameter
- update construction sites
- update `MapObjectPresentationSampler` to accept movement explicitly
- update `SpriteSnapshotBuilder`
- build and fix compile errors

Validation:

```bash
swift build --package-path Packages/RagnarokGame
```

### Phase 3: Move replanning into backends

- add `objectMovements` to Reality
- add `objectMovements` to Metal
- move `MapObjectMovementPlanner.replan` calls from `MapScene+EventHandler` into `moveObject(_:)`
- implement `stopObject(objectID:at:)`
- clear movement on removal/unload/detach

Validation:

```bash
swift build --package-path Packages/RagnarokGame
```

### Phase 4: Update MapScene event handlers

- remove direct `MapObjectMovementPlanner` usage from `MapScene`
- replace player movement replan with `renderBackend.moveObject`
- replace object movement replan with `renderBackend.moveObject`
- replace stop handling with `renderBackend.stopObject`
- update `playerMovementOrigin()` to query the backend
- keep logical `state.objects[id].gridPosition` updates

Search checks:

```bash
rg -n "movement|MapObjectMovementPlanner|replan|playerMovementOrigin|moveObject|stopObject" Packages/RagnarokGame/Sources/RagnarokGame/Core Packages/RagnarokGame/Sources/RagnarokGame/Metal Packages/RagnarokGame/Sources/RagnarokGame/Reality
```

Validation:

```bash
swift build --package-path Packages/RagnarokGame
```

### Phase 5: Runtime validation

Manual checks should cover both Reality and Metal:

- player movement starts smoothly
- chained player movement replans smoothly
- player movement origin for joystick input follows presentation position
- pending arrival actions still fire after movement finishes
- monster movement still animates
- movement packets for missing objects still add then move the object
- stop packets clear movement and settle to idle
- object vanish clears movement
- player death does not remove the player
- visionOS tile grid follows player movement in Reality
- Metal camera follows player presentation position
- overlay gauges follow moving objects
- combat text starts at current presentation position

## Risk Areas

- `pendingArrivalAction` depends on movement duration. Handle this explicitly before removing `MapScene`'s local movement state.
- `MapObjectPresentationSampler` precedence can regress attacks or death animations if movement blindly overrides `object.presentation`.
- Reality and Metal must use the same replanning helper to avoid visible backend divergence.
- Removing objects must clear backend movement state; otherwise stale movement can affect later object IDs if reused.
- Player position queries must be available before the first rendered frame; use logical grid position fallback when no presentation snapshot exists yet.
