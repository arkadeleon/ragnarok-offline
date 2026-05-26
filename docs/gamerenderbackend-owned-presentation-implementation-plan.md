# GameRenderBackend-Owned Presentation Implementation Plan

## Context

`MapSceneObject` currently carries `presentation: MapObjectPresentationState`. After moving object movement toward backend ownership, presentation is the next render-facing state still stored in the logical scene object.

`presentation` currently combines:

- facing state: `direction` and `headDirection`
- action state: idle, walk, attack, skill, pickup, sit, die, and related sprite actions
- timing state: `startTime` and `completion`

The target design is to remove `presentation` from `MapSceneObject` and make object presentation a `GameRenderBackend` responsibility. `MapScene` should still interpret gameplay packets and decide which high-level action command should be issued, but it should not store current sprite presentation state on logical objects.

## Goals

- Remove `presentation` from `MapSceneObject`.
- Move facing, action, and presentation timing state into each render backend.
- Keep `MapScene` responsible for packet interpretation and action selection.
- Keep movement and presentation state colocated in the backend so sampling can use a single presentation source.
- Preserve Reality and Metal behavior for movement, actions, direction changes, player death, overlays, combat text, and camera tracking.

## Non-Goals

- Do not move object stats, status, appearance, HP/SP, or logical grid position out of `MapSceneObject`.
- Do not move packet interpretation into render backends.
- Do not make render backends decide combat semantics such as damage, hit count, or sound table selection.
- Do not remove `MapObjectPresentationState`; it remains useful as a backend-owned runtime model.
- Do not redesign `MapObjectAnimationState`, `MapObjectAnimationCompletion`, or sprite rendering in this pass.

## Target API

Extend `GameRenderBackend` with presentation-specific commands.

Recommended shape:

```swift
struct MapObjectPresentationCommand: Sendable {
    var objectID: GameObjectID
    var action: SpriteActionType
    var startTime: ContinuousClock.Instant
    var completion: MapObjectAnimationCompletion
}
```

Protocol additions and adjusted object creation:

```swift
@MainActor
protocol GameRenderBackend: AnyObject {
    func attach(scene: MapScene)
    func detach()

    func load(progress: Progress) async
    func unload()

    func updateCamera(_ cameraState: MapCameraState)

    func addObject(
        _ object: MapSceneObject,
        direction: SpriteDirection,
        headDirection: SpriteHeadDirection
    )
    func updateObject(_ object: MapSceneObject)
    func moveObject(_ command: MapObjectMoveCommand) -> MapObjectMovementState?
    func stopObject(objectID: GameObjectID, at position: SIMD2<Int>)
    func turnObject(
        objectID: GameObjectID,
        direction: SpriteDirection,
        headDirection: SpriteHeadDirection
    )
    func playObjectAction(_ command: MapObjectPresentationCommand)
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

Notes:

- `addObject` takes initial direction/head direction because new objects need an initial facing state.
- `updateObject` remains for logical object changes such as HP, status, appearance, speed, and cloak.
- `turnObject` is explicit because direction packets should not require mutating logical object state.
- `playObjectAction` intentionally does not carry direction/head direction. The backend should reuse the current presentation direction unless a separate turn command changes it.
- `moveObject` can update presentation to walk internally, based on the movement planner result.
- `stopObject` can settle presentation to idle internally.

## Data Model Changes

### MapSceneObject

Remove:

```swift
public var presentation: MapObjectPresentationState
```

Remove the initializer parameter:

```swift
presentation: MapObjectPresentationState
```

Keep:

- `gridPosition`
- `speed`
- appearance fields such as job, gender, hair, weapon, headgear, robe
- status fields such as body, health, and effect state
- HP/SP fields

### Backend runtime state

Both backends should maintain:

```swift
private var objectPresentations: [GameObjectID : MapObjectPresentationState] = [:]
```

If the movement ownership refactor is already in place, this sits next to:

```swift
private var objectStates: [GameObjectID : MapSceneObject] = [:]
private var objectMovements: [GameObjectID : MapObjectMovementState] = [:]
```

Backends should provide a default presentation for missing entries:

```swift
MapObjectPresentationState(
    action: .idle,
    direction: .south,
    headDirection: .lookForward,
    startTime: .now,
    completion: .indefinite
)
```

Use the default only as a fallback. Normal add paths should insert an explicit initial presentation.

## MapScene Changes

### Initial player object

`MapScene.init` should create the player `MapSceneObject` without presentation.

After `load(progress:)`, initial render sync should pass initial facing into the backend:

```swift
renderBackend.addObject(
    state.player,
    direction: .south,
    headDirection: .lookForward
)
renderBackend.updateCamera(cameraState)
```

If the initial player direction is available from the login/map entry packet later, use that source instead of hard-coding `.south`.

### Spawn event

`onMapObjectSpawned` should create a logical `MapSceneObject` without presentation, then call:

```swift
renderBackend.addObject(
    sceneObject,
    direction: SpriteDirection(direction: direction),
    headDirection: SpriteHeadDirection(headDirection: headDirection)
)
```

### Movement events

`onPlayerMoved` and `onMapObjectMoved` should:

- update logical `gridPosition`
- call `moveObject(_:)`
- not write walk presentation into `MapSceneObject`

The backend should set presentation to walk using the movement planner's final direction and remaining duration.

If `MapScene` still needs movement duration for arrival actions, it can continue using the `MapObjectMovementState?` returned by `moveObject(_:)`.

### Stop event

`onMapObjectStopped` should:

- update logical `gridPosition`
- call `stopObject(objectID:at:)`
- not write idle presentation into `MapSceneObject`

The backend should remove movement and settle presentation to idle while preserving current direction/head direction.

### Direction event

`onMapObjectDirectionChanged` should stop mutating object presentation and call:

```swift
renderBackend.turnObject(
    objectID: objectID,
    direction: SpriteDirection(direction: direction),
    headDirection: SpriteHeadDirection(headDirection: headDirection)
)
```

No logical object mutation is needed unless there is another non-presentation state attached to the packet.

### Action event

`onMapObjectActionPerformed` should still choose `presentationAction` and `completion`, because that depends on packet semantics and object appearance data.

Instead of mutating `object.presentation`, call:

```swift
renderBackend.playObjectAction(
    MapObjectPresentationCommand(
        objectID: sourceID,
        action: presentationAction,
        startTime: now,
        completion: completion
    )
)
```

Keep combat text and sound handling unchanged.

### Skill event

`onMapObjectSkillPerformed` should still choose `.skill` versus `.attack1` based on available action types for the source job.

Then call `playObjectAction(_:)` instead of mutating object presentation.

### Vanish and resurrect

Player death vanish should call:

```swift
renderBackend.playObjectAction(
    MapObjectPresentationCommand(
        objectID: objectID,
        action: .die,
        startTime: .now,
        completion: .indefinite
    )
)
```

Do not call `removeObject` for player death.

Resurrection should call:

```swift
renderBackend.playObjectAction(
    MapObjectPresentationCommand(
        objectID: objectID,
        action: .idle,
        startTime: .now,
        completion: .indefinite
    )
)
```

### Logical updates

Handlers that only change logical data continue calling `updateObject(_:)`:

- HP/SP changes
- max HP/SP changes
- status/effect changes, including cloak
- sprite/appearance changes
- speed changes if added later

## Backend Presentation Semantics

Both backends should centralize presentation updates in shared helpers.

Recommended helper:

```swift
private func presentation(for objectID: GameObjectID) -> MapObjectPresentationState
```

Recommended mutating helpers:

```swift
private func setPresentation(
    objectID: GameObjectID,
    action: SpriteActionType,
    startTime: ContinuousClock.Instant,
    completion: MapObjectAnimationCompletion
)

private func setFacing(
    objectID: GameObjectID,
    direction: SpriteDirection,
    headDirection: SpriteHeadDirection
)
```

`setPresentation` should preserve current direction/head direction.

`setFacing` should preserve current action, start time, and completion unless the caller intentionally issues an action command too.

## RealityRenderBackend Changes

Reality currently passes `object.presentation` into `MapObjectSnapshotPresentationComponent`.

Change the component update to use backend-owned presentation:

```swift
let presentation = objectPresentations[object.objectID] ?? defaultPresentation
entity.components.set(MapObjectSnapshotPresentationComponent(
    logicalWorldPosition: scene.mapGrid.worldPosition(for: object.gridPosition),
    timeline: objectMovementTimeline(for: object.objectID),
    presentation: presentation
))
```

### Add object

`addObject(_:direction:headDirection:)` should:

- store `objectStates[object.objectID] = object`
- insert initial `objectPresentations[object.objectID]`
- upsert the entity

Initial presentation:

```swift
MapObjectPresentationState(
    action: .idle,
    direction: direction,
    headDirection: headDirection,
    startTime: .now,
    completion: .indefinite
)
```

### Update object

`updateObject(_:)` should:

- update logical object cache
- keep existing presentation unchanged
- upsert entity and sprite configuration as needed

### Move object

`moveObject(_:)` should:

- replan movement
- store movement
- set presentation action to `.walk`
- set direction to `movement.finalDirection`
- preserve current head direction
- set completion to `.after(remainingDuration, settledAction: .idle)`
- update the entity presentation component
- refresh visionOS tile entities for player movement

### Stop object

`stopObject(objectID:at:)` should:

- remove movement
- set presentation action to `.idle`
- preserve current direction/head direction
- set completion to `.indefinite`
- update entity presentation component
- refresh visionOS tile entities for the player

### Turn object

`turnObject(objectID:direction:headDirection:)` should:

- update `objectPresentations`
- update entity presentation component

### Play action

`playObjectAction(_:)` should:

- update `objectPresentations`
- preserve current direction/head direction
- update entity presentation component

### Remove object

`removeObject(objectID:)` should remove:

- Reality object entity
- object state cache
- movement state
- presentation state

## MetalRenderBackend Changes

Metal currently builds `SpriteSnapshot` by sampling `object.presentation`.

Change `SpriteSnapshotBuilder` to accept presentations:

```swift
func build(
    objects: [GameObjectID : MapSceneObject],
    movements: [GameObjectID : MapObjectMovementState],
    presentations: [GameObjectID : MapObjectPresentationState],
    items: [GameObjectID : MapSceneItem],
    scene: MapScene
) -> [GameObjectID : SpriteSnapshot]
```

Object snapshot sampling should use:

```swift
let presentation = presentations[object.objectID] ?? defaultPresentation
let sample = sampler.sample(
    object: object,
    movement: movement,
    presentation: presentation,
    position: { scene.mapGrid.worldPosition(for: $0) },
    now: now
)
```

### Add/update object

`addObject(_:direction:headDirection:)` should insert object state and initial presentation.

`updateObject(_:)` should update object state without changing presentation.

Both should refresh drawables.

### Move/stop/turn/action

Each presentation-affecting command should update `objectPresentations`, then refresh drawables.

For player movement and stop, also update the camera target after refreshing snapshots.

### Remove object

Remove:

- `objectStates[objectID]`
- `objectMovements[objectID]`
- `objectPresentations[objectID]`
- `spriteSnapshots[objectID]`

Then refresh drawables.

## Presentation Sampler Changes

`MapObjectPresentationSampler` should no longer read presentation from `MapSceneObject`.

Change:

```swift
func sample(
    for object: MapSceneObject,
    movement: MapObjectMovementState?,
    position: (SIMD2<Int>) -> SIMD3<Float>,
    now: ContinuousClock.Instant
) -> PresentationSample
```

to:

```swift
func sample(
    for object: MapSceneObject,
    movement: MapObjectMovementState?,
    presentation: MapObjectPresentationState,
    position: (SIMD2<Int>) -> SIMD3<Float>,
    now: ContinuousClock.Instant
) -> PresentationSample
```

The lower-level sampling API that already accepts `presentation` can remain.

Important precedence rule:

- active movement may produce walk animation
- non-walk action commands such as attack, skill, pickup, sit, hurt, and die must not be overwritten by stale movement

If current behavior lets movement override all actions while moving, preserve it for this refactor and defer animation precedence changes to a separate behavior patch.

## Implementation Phases

### Phase 1: Add presentation command API

- add `MapObjectPresentationCommand`
- extend `GameRenderBackend`
- add temporary backend implementations that still use existing object presentation where needed
- build `Packages/RagnarokGame`

Validation:

```bash
swift build --package-path Packages/RagnarokGame
```

### Phase 2: Introduce backend presentation caches

- add `objectPresentations` to Reality
- add `objectPresentations` to Metal
- update add/update/move/stop/remove methods to maintain presentation cache
- keep `MapSceneObject.presentation` temporarily as a compatibility source
- build

Validation:

```bash
swift build --package-path Packages/RagnarokGame
```

### Phase 3: Migrate event handlers

- replace direction mutations with `turnObject`
- replace action mutations with `playObjectAction`
- replace death/resurrection presentation mutations with `playObjectAction`
- remove walk/idle presentation writes from move/stop handlers
- keep logical object updates and `updateObject` calls only for logical state changes
- build

Search check:

```bash
rg -n "\\.presentation|MapObjectPresentationState" Packages/RagnarokGame/Sources/RagnarokGame/Core
```

Expected remaining references in `Core` should be command construction and presentation model definitions, not `MapSceneObject` mutation.

### Phase 4: Remove presentation from MapSceneObject

- remove the `presentation` property
- remove initializer parameter
- update all construction sites
- update `MapObjectPresentationSampler`
- update `SpriteSnapshotBuilder`
- update Reality presentation component writes
- build

Validation:

```bash
swift build --package-path Packages/RagnarokGame
```

### Phase 5: Runtime validation

Manual checks should cover both Metal and Reality:

- initial player appears idle and facing the expected direction
- spawned monsters/NPCs face the packet direction
- direction packets update facing and head direction
- player movement animates as walking
- object movement animates as walking
- stop packets settle objects to idle
- chained movement still replans smoothly
- attack actions use the correct job/gender/weapon action
- skill actions use `.skill` when available and fallback to attack otherwise
- pickup action plays and settles to idle
- sit/stand actions behave as before
- player death plays die animation and does not remove the player
- resurrection returns the player to idle
- cloak still hides objects through `updateObject`
- sprite appearance changes preserve current presentation
- Metal camera still follows player presentation position
- overlay gauges and combat text still use presentation world positions

## Risk Areas

- Existing direction/head direction must be preserved when playing an action command.
- Appearance updates must not reset action or facing.
- Missing initial presentations can make new objects default to the wrong direction.
- Movement and action precedence can subtly change visible animation behavior.
- Player death must remain an action update, not object removal.
- Reality component updates and Metal snapshot building must use the same presentation source to avoid backend divergence.
