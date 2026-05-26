# GameRenderBackend Incremental API Implementation Plan

## Context

`GameRenderBackend.applySnapshot(_:)` is currently the only entry point that `MapScene` uses to synchronize runtime state into the render backend. It treats `MapSceneState` as the authoritative snapshot, and each backend either diffs or rebuilds its render state from that snapshot.

The goal is to replace that full-snapshot entry point with event-style incremental APIs so `MapScene` can notify the backend directly while handling packets and gameplay events:

- object add/update/remove
- item add/remove
- camera update

This refactor intentionally does not keep an `applySnapshot(_:)` / `reconcileSnapshot(_:)` fallback. The event handling layer becomes responsible for calling the matching backend method after it mutates `MapSceneState`.

## Target Backend API

Change `Packages/RagnarokGame/Sources/RagnarokGame/Core/GameRenderBackend.swift`:

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
    func removeObject(id: GameObjectID)

    func addItem(_ item: MapSceneItem)
    func removeItem(id: GameObjectID)

    func showSelection(at position: SIMD2<Int>, mapGrid: MapGrid)
    func addCombatText(_ combatText: MapSceneCombatText)
    func addEffect(_ effect: MapSceneEffect)
    func playSound(named soundName: String, on objectID: GameObjectID)
}
```

Explicit non-goals:

- no `updateItem`; current item event surface is spawn/remove only
- no protocol-level `prepareFrame`; Metal already owns it, Reality can rely on scene subscriptions
- no protocol-level transient cleanup API; each backend handles combat text/effect expiry internally
- no protocol-level overlay projection API; overlay positions are updated from each backend's frame path
- no protocol-level visible tile update API; Reality handles visionOS tile entities internally
- no `applySnapshot` fallback

## MapScene Changes

### Remove snapshot push path

Remove or stop using:

- `MapScene.applySnapshot()`
- `GameRenderBackend.applySnapshot(_:)`
- calls to `applySnapshot()` in event handlers

### Initial render state

Because `MapScene.load(progress:)` will no longer call `applySnapshot()`, ensure the initial state is pushed explicitly.

Recommended flow:

```swift
func load(progress: Progress) async {
    await renderBackend.load(progress: progress)
    renderBackend.addObject(state.player)
    renderBackend.updateCamera(cameraState)
}
```

Reality currently creates the player entity inside `load(progress:)`. During this refactor, avoid double-adding the player by choosing one of these approaches:

- move player entity creation out of `RealityRenderBackend.load(progress:)` and into `addObject(_:)`
- or make `addObject(_:)` idempotent and reuse/update an already-created player entity

The first option keeps lifecycle responsibilities cleaner.

### Camera updates

Change `cameraState.didSet` from snapshot push to:

```swift
renderBackend.updateCamera(cameraState)
```

Metal also needs camera target position. `MetalRenderBackend.updateCamera(_:)` can store the camera state, then use the current player snapshot/world position when refreshing frame state.

## Event Handler Mapping

Each event handler should update `MapSceneState` first, then call the matching backend method with the final state value.

### Player parameter and recovery events

For HP/SP/max changes:

- update `state.player`
- update `state.overlay.gauges`
- call `renderBackend.updateObject(state.player)`
- keep `addCombatText(_:)` calls unchanged

Affected handlers:

- `onPlayerParameterChanged(_:)`
- `onPlayerHealthPointsRecovered(hp:amount:)`
- `onPlayerSpellPointsRecovered(sp:amount:)`

### Player movement

After updating `state.player.gridPosition`, `movement`, and `presentation`:

```swift
renderBackend.updateObject(state.player)
```

Affected handler:

- `onPlayerMoved(startPosition:endPosition:)`

### Object spawn

After inserting into `state.objects`:

```swift
renderBackend.addObject(state.objects[object.objectID]!)
```

Also keep monster gauge creation unchanged.

Affected handler:

- `onMapObjectSpawned(object:position:direction:headDirection:)`

### Object movement

Current behavior creates a missing object if a move packet arrives before spawn.

Mapping:

- if object already exists: update state, then `updateObject`
- if object does not exist: create state, then `addObject`

Affected handler:

- `onMapObjectMoved(object:startPosition:endPosition:)`

### Object stop, direction, status, sprite, action, skill

These mutate existing object state. After writing back to `state.objects[objectID]`, call:

```swift
if let object = state.objects[objectID] {
    renderBackend.updateObject(object)
}
```

Affected handlers:

- `onMapObjectStopped(objectID:position:)`
- `onMapObjectDirectionChanged(objectID:direction:headDirection:)`
- `onMapObjectStateChanged(objectID:bodyState:healthState:effectState:)`
- `onMapObjectSpriteChanged(_:)`
- `onMapObjectActionPerformed(objectAction:)`
- `onMapObjectSkillPerformed(_:)`
- `onMapObjectHealthUpdated(_:)`
- `onMapObjectResurrected(objectID:)`

Important details:

- `effectState == .cloak` is an `updateObject`, not `removeObject`
- sprite appearance changes are `updateObject`; backend handles sprite reload as needed
- player death is `updateObject` with `.die`, not `removeObject`

### Object vanish

Preserve current player death behavior:

- player death vanish: update player presentation to `.die`, set `state.isPlayerDead`, remove overlay gauge, then `updateObject`
- all other vanish cases: remove from `state.objects`, remove overlay gauge, then `removeObject(id:)`

Affected handler:

- `onMapObjectVanished(objectID:type:)`

### Item spawn/remove

Mapping:

- `onItemSpawned`: insert into `state.items`, then `addItem`
- `onItemVanished`: remove from `state.items`, then `removeItem`

No `updateItem` is required for the current event surface.

## RealityRenderBackend Implementation

Reality should become a direct entity-cache updater.

### Add object

`addObject(_:)` should:

- create or fetch `entityCache.objectEntity(for:)`
- set name, transform, visibility, `GridPositionComponent`, `MapSceneObjectComponent`, and `MapObjectSnapshotPresentationComponent`
- attach entity to `rootEntity` if needed
- load/reload sprite if the `ComposedSprite.Configuration` changed
- if this object is the player and the camera is not yet parented, set up the world camera target

Most of this can be extracted from current `syncObjectEntity(for:scene:)`.

### Update object

`updateObject(_:)` can share most of the implementation with `addObject(_:)`, because Reality's cache lookup already gives upsert behavior.

Keep these semantics:

- cloak toggles `entity.isEnabled`
- movement/presentation updates refresh `MapObjectSnapshotPresentationComponent`
- sprite configuration changes reload the child sprite
- stale async sprite loads must not attach old sprites after configuration changes

### Remove object

`removeObject(id:)` should:

- call `entityCache.removeObjectEntity(for:)`
- keep player death out of this path; player death is an update to `.die`

### Add/remove item

`addItem(_:)` should be extracted from current `syncItemEntity(for:scene:)`.

`removeItem(id:)` should call:

```swift
entityCache.removeItemEntity(for: id)
```

Consider adding a stale-load guard for item sprite loading, similar to the object sprite configuration check, so an item removed before its async load completes cannot reattach a sprite.

### Update camera

`updateCamera(_:)` already exists in Reality. Keep it as the protocol implementation.

Reality-specific per-frame work remains backend-owned:

- scene subscription driven updates
- overlay projection
- visionOS visible tile entity updates
- transient entity/system cleanup

## MetalRenderBackend Implementation

Metal should store object/item state incrementally, but keep drawables rebuilt from current state.

### State caches

Add private caches:

```swift
private var objectStates: [GameObjectID : MapSceneObject] = [:]
private var itemStates: [GameObjectID : MapSceneItem] = [:]
private var cameraState: MapCameraState = .default
```

`spriteSnapshots` remains the per-frame/per-refresh presentation cache used by hit testing, overlay projection, combat text placement, and camera target fallback.

### Add/update/remove methods

Implement:

```swift
func addObject(_ object: MapSceneObject) {
    objectStates[object.objectID] = object
    refreshSpriteDrawables()
}

func updateObject(_ object: MapSceneObject) {
    objectStates[object.objectID] = object
    refreshSpriteDrawables()
}

func removeObject(id: GameObjectID) {
    objectStates.removeValue(forKey: id)
    spriteSnapshots.removeValue(forKey: id)
    refreshSpriteDrawables()
}

func addItem(_ item: MapSceneItem) {
    itemStates[item.objectID] = item
    refreshSpriteDrawables()
}

func removeItem(id: GameObjectID) {
    itemStates.removeValue(forKey: id)
    spriteSnapshots.removeValue(forKey: id)
    refreshSpriteDrawables()
}
```

`refreshSpriteDrawables()` should replace the old `updateObjects(objects:items:scene:)` path:

```swift
private func refreshSpriteDrawables() {
    guard let scene else {
        return
    }

    let snapshots = spriteSnapshotBuilder.build(
        objects: objectStates,
        items: itemStates,
        scene: scene
    )
    spriteSnapshots = snapshots
    renderer.spriteDrawables = spriteAssetStore?.sync(snapshots: snapshots) ?? []
}
```

This intentionally rebuilds Metal drawables together. It is acceptable because:

- sprite animation frames depend on `ContinuousClock.now`
- sprite direction depends on camera azimuth
- drawables need depth sorting
- async asset completion can make an object drawable appear without a new gameplay event

### Prepare frame

Keep `MetalRenderBackend.prepareFrame()` and make it the frame-level update path:

```swift
func prepareFrame() {
    removeExpiredCombatTexts()
    removeExpiredEffects()
    refreshSpriteDrawables()
    updateCameraTarget()
    syncAndProjectOverlay()
}
```

`updateCameraTarget()` should choose:

- `spriteSnapshots[playerID]?.worldPosition`
- otherwise `scene.mapGrid.worldPosition(for: scene.state.player.gridPosition)`

Then call:

```swift
renderer.updateCamera(cameraState: cameraState, targetPosition: targetPosition)
```

### Update camera

`updateCamera(_:)` should store the camera state and refresh drawables/camera target:

```swift
func updateCamera(_ cameraState: MapCameraState) {
    self.cameraState = cameraState
    refreshSpriteDrawables()
    updateCameraTarget()
}
```

This preserves camera-relative sprite direction updates without requiring a full snapshot.

### Resource cleanup

Extend `clearRenderResources()` to clear:

- `objectStates`
- `itemStates`
- `spriteSnapshots`

`SpriteAssetStore.sync(snapshots:)` can continue pruning assets that are no longer present in the rebuilt snapshot set.

## SpriteAssetStore Changes

Minimal path:

- keep `sync(snapshots:)`
- continue using it from `refreshSpriteDrawables()`

No public per-object asset API is required for the first implementation.

Optional cleanup:

- rename `sync(snapshots:)` to clarify that it both prunes asset caches and returns drawables
- keep this as a follow-up unless the current naming becomes misleading during the refactor

## Ordering and Consistency Rules

Use these rules throughout event handlers:

- mutate `MapSceneState` first
- update overlay state next
- call backend with the final `MapSceneObject` / `MapSceneItem`
- trigger transient render events such as combat text, skill effects, and sounds after the state update

This keeps backend placement logic aligned with the latest state.

Special cases:

- player death vanish updates object presentation and calls `updateObject`
- non-player vanish removes the object and calls `removeObject`
- cloak updates object visibility and calls `updateObject`
- missing object movement creates state and calls `addObject`

## Implementation Phases

### Phase 1: Protocol and compile-driven call site migration

- update `GameRenderBackend`
- remove `applySnapshot(_:)` requirement
- add stub methods to both backend implementations
- replace `MapScene.cameraState.didSet`
- replace `MapScene.load(progress:)` initial sync
- remove or empty `MapScene.applySnapshot()`

Build target:

```bash
swift build --package-path Packages/RagnarokGame
```

### Phase 2: Reality backend extraction

- extract current object sync logic into add/update helpers
- extract current item sync logic into add/remove helpers
- adjust `load(progress:)` so dynamic player entity setup does not conflict with `addObject`
- keep Reality camera setup/update behavior intact

Build target:

```bash
swift build --package-path Packages/RagnarokGame
```

### Phase 3: Metal backend cache and redraw path

- introduce `objectStates`, `itemStates`, and stored `cameraState`
- replace `syncFrameState(with:)` object/item snapshot usage with cache-driven `refreshSpriteDrawables()`
- keep `prepareFrame()` as the frame path for animation, overlay, camera target, and transient cleanup
- clear new caches on unload/detach

Build target:

```bash
swift build --package-path Packages/RagnarokGame
```

### Phase 4: Event handler migration

- replace each `applySnapshot()` call with the specific backend method
- preserve combat text, effect, and sound event calls
- verify special cases listed above

Recommended search checks:

```bash
rg -n "applySnapshot|renderBackend\\.addObject|renderBackend\\.updateObject|renderBackend\\.removeObject|renderBackend\\.addItem|renderBackend\\.removeItem" Packages/RagnarokGame/Sources/RagnarokGame
```

Build target:

```bash
swift build --package-path Packages/RagnarokGame
```

## Validation Checklist

Manual validation should cover both Metal and Reality backends:

- map load shows player
- camera reset/rotation updates view
- player movement animates and camera follows
- monster spawn appears
- monster movement updates presentation
- direction changes update facing
- cloak hides object without removing it permanently
- sprite changes reload visible equipment/body parts
- non-player vanish removes entity/sprite
- player death shows death animation instead of removing player
- item spawn appears
- item pickup/removal disappears
- combat text still appears at current target position
- skill effects and sounds still play
- overlay gauges still follow moving objects

Automated validation:

```bash
swift build --package-path Packages/RagnarokGame
```

If changes touch shared movement or packet behavior, add the smallest relevant package test run available for that layer.
