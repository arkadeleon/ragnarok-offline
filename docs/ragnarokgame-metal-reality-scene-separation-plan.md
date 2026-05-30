# RagnarokGame Metal / Reality Scene Separation Plan

## Goal

Separate the Metal and Reality map stacks from the `MapScene` level instead of sharing one scene plus backend abstraction.

Target outcome:

- iOS and macOS use only the Metal path.
- visionOS uses only the RealityKit path.
- `MapScene` is replaced by platform-specific scene roots:
  - `MetalMapScene`
  - `RealityMapScene`
- A small `GameMapScene` protocol may exist, but only for lifecycle / packet routing. It must not expose shared runtime data.
- Metal and Reality no longer share `Core/Runtime/**` scene data.
- Reality returns to the pre-`767b840af59fa6d83b57332e7a9307c7c464e533` ECS-style model.
- Metal is free to be redesigned as an object-oriented runtime without preserving Reality data shapes.
- `MapView` is split by platform. The Reality view does not include `ThumbstickView` or `ActionControlPadView`.

Note: commit `767b840a` itself adds `docs/mapview-rendering-refactor-implementation-plan.md`. The useful Reality ECS reference is the parent state, `767b840a^`, especially:

- `Packages/RagnarokGame/Sources/RagnarokGame/Engine/Scene/MapScene.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Engine/ECS/**`
- `Packages/RagnarokGame/Sources/RagnarokGame/Client/Views/MapSceneRealityView.swift`

## Current Problem

The current architecture still has a shared `MapScene` and a shared `GameRenderBackend` protocol.

The shared runtime types under `Core/Runtime` are used by both Metal and Reality:

- `MapSceneState`
- `MapSceneObject`
- `MapSceneItem`
- `MapSceneCombatText`
- `MapSceneEffect`
- `MapCameraState`
- `MapObjectMovementState`
- `MapObjectAnimationState`

This makes the two renderers pay for each other's model decisions:

- Reality carries backend-owned movement / animation state through `MapSceneObjectComponent`.
- Metal is constrained by state names and packet flow designed to be shared with Reality.
- `MapRenderHost` still routes by `GameRenderConfiguration`.
- `MapView` is one view that mixes iOS/macOS controls with visionOS lifecycle behavior.

## Target Architecture

### Platform Routing

`GameSession` should create the platform scene directly:

```swift
#if os(visionOS)
let scene = RealityMapScene(...)
#else
let scene = MetalMapScene(...)
#endif
```

`GameRenderConfiguration`, `GameRenderEngine`, `MapRenderHost`, and `GameRenderBackend` should disappear after the migration. There should be no supported runtime backend switch between Metal and Reality.

### Shared Code That Can Stay

The split is about map runtime and renderer ownership, not about duplicating all utility code.

Allowed shared code:

- login / character / network session flow
- packet models from `RagnarokPackets`
- game data models from `RagnarokModels`
- resource loading through `RagnarokResources`
- asset formats and render assets
- localization tables
- low-level utilities such as `MapGrid`, `PathFinder`, `GameObjectID`, and sound/effect lookup tables
- common non-map UI widgets where they are still useful

Not allowed to remain shared between Metal and Reality:

- map scene state objects
- map object / item runtime records
- movement timeline state
- animation presentation state
- combat text runtime records
- effect runtime records
- map camera runtime state
- backend protocol command models

### Scene Protocol

If a protocol is useful, keep it intentionally small:

```swift
@MainActor
protocol GameMapScene: AnyObject {
    var mapName: String { get }
    func load(progress: Progress) async
    func unload()
}
```

Packet and gameplay entry points may use another protocol only if it uses packet/domain inputs, not shared runtime types:

```swift
@MainActor
protocol GameMapSceneEventHandling: AnyObject {
    func onPlayerMoved(startPosition: SIMD2<Int>, endPosition: SIMD2<Int>)
    func onMapObjectSpawned(object: MapObject, position: SIMD2<Int>, direction: Direction, headDirection: HeadDirection)
    func onMapObjectMoved(object: MapObject, startPosition: SIMD2<Int>, endPosition: SIMD2<Int>)
    func onMapObjectStopped(objectID: GameObjectID, position: SIMD2<Int>)
    func onMapObjectVanished(objectID: GameObjectID)
    func onItemSpawned(item: MapItem, position: SIMD2<Int>)
    func onItemVanished(objectID: GameObjectID)
}
```

The protocol should not contain `MapSceneObject`, `MapSceneState`, `MapObjectMovementState`, or renderer-specific types.

## Target Reality Shape

Reality should be visionOS-only and should look close to the `767b840a^` ECS model:

- `RealityMapScene`
  - owns `rootEntity`
  - owns `worldCameraEntity`
  - owns tile selector entity
  - owns `SpriteEntityManager`
  - owns `TileEntityManager`
  - owns `PathFinder`
  - handles Reality gestures and targeted entity interactions
- ECS components:
  - `GridPositionComponent`
  - `MapObjectComponent`
  - `MapItemComponent`
  - `HealthPointsComponent`
  - `SpellPointsComponent`
  - `WalkingComponent`
  - `SpriteActionComponent`
  - `SpriteAnimationComponent`
  - `SpriteAnimationLibraryComponent`
  - `SpriteBillboardComponent`
  - `TileComponent`
  - current combat/effect components only if they fit the ECS model
- ECS systems:
  - `WalkingSystem`
  - `SpriteActionSystem`
  - `SpriteAnimationSystem`
  - `SpriteBillboardSystem`
  - combat text / effect systems as Reality-only systems

Reality should not reference:

- `MapSceneObject`
- `MapSceneState`
- `MapSceneItem`
- `MapObjectAnimationState`
- `MapObjectMovementState`
- `GameRenderBackend`
- Metal renderer/resource state

## Target Metal Shape

Metal should be iOS/macOS-only and can be redesigned around objects.

Suggested structure:

- `MetalMapScene`
  - owns map lifecycle
  - owns map grid and path finding
  - owns player input and interaction decisions
  - owns a `MetalMapObjectRegistry`
  - owns a `MetalMapItemRegistry`
  - owns `MetalMapRenderer`
  - owns Metal audio / effects / combat text runtimes
- `MetalMapObject`
  - base class for object identity, appearance, status, grid position, movement, and animation
- `MetalPlayerObject`
  - player-specific HP/SP, camera target, command helpers
- `MetalMonsterObject`
  - monster-specific targeting and combat feedback
- `MetalNPCObject`
  - talk target behavior
- `MetalMapItem`
  - item sprite / pickup behavior
- `MetalMovementController`
  - path replanning and sampling
- `MetalAnimationController`
  - action, direction, head direction, completion timing
- `MetalCombatTextRuntime`
- `MetalSkillEffectRuntime`
- `MetalCameraController`

Metal should not reference Reality ECS components or shared `Core/Runtime` scene records.

## Phase Plan

Each phase should be small enough to land as one focused commit.

### Phase 1: Add Platform Scene Aliases

Objective:

- Prepare `GameSession` for platform-specific scene roots without changing behavior yet.

Changes:

- Add `GameMapScene` lifecycle protocol.
- Add temporary platform aliases:
  - `typealias MetalMapScene = MapScene` for non-visionOS during transition.
  - `typealias RealityMapScene = MapScene` for visionOS during transition.
- Update `GameSession.MapPhase.loaded` and convenience accessors to use the platform scene alias where possible.

Acceptance:

- No runtime behavior change.
- `swift build --package-path Packages/RagnarokGame` still succeeds.

### Phase 2: Split The Map Screen Views

Objective:

- Separate platform UI shells before changing scene internals.

Changes:

- Create a non-visionOS Metal map screen from the current `MapView` behavior.
- Create a visionOS Reality map screen that only owns visionOS window / immersive-space coordination.
- Keep `ThumbstickView` and `ActionControlPadView` only in the Metal screen.
- Keep Reality interaction inside `RealityMapView` / Reality gestures.

Recommended names:

- `MetalMapScreen`
- `RealityMapScreen`
- Keep `MetalMapView` name for the MTK surface only, or rename that surface to `MetalMapSurfaceView` before taking `MetalMapView` for the full map screen.

Acceptance:

- iOS/macOS map UI still has thumbstick, action pad, chat, menu, overlays.
- visionOS no longer compiles a map screen path that contains `ThumbstickView` or `ActionControlPadView`.
- `rg "ThumbstickView|ActionControlPadView" Packages/RagnarokGame/Sources/RagnarokGame/Reality` returns no matches.

### Phase 3: Lock Backend Selection To Platform

Objective:

- Remove the runtime idea that either platform can choose either renderer.

Changes:

- Stop reading `GameRenderConfiguration` in map screen routing.
- In `GameSession`, create the Reality backend only under `#if os(visionOS)` and the Metal backend only under `#else`.
- Make `MapRenderHost` a temporary compatibility wrapper or remove it if Phase 2 already bypasses it.

Acceptance:

- visionOS cannot instantiate Metal map rendering through `RagnarokGame`.
- iOS/macOS cannot instantiate Reality map rendering through `RagnarokGame`.
- Existing behavior remains visually close to current behavior.

### Phase 4: Restore A Reality ECS Scene Skeleton

Objective:

- Add the future Reality lane without switching production flow yet.

Changes:

- Add `RealityMapScene` under a visionOS-only Reality folder.
- Use `767b840a^` as the reference for:
  - `rootEntity`
  - `worldCameraEntity`
  - tile selector
  - `SpriteEntityManager`
  - `TileEntityManager`
  - component registration
  - system registration
- Add old-style components that are missing today:
  - `GridPositionComponent`
  - `MapObjectComponent`
  - `MapItemComponent`
  - `HealthPointsComponent`
  - `SpellPointsComponent`
- Keep it unconnected from `GameSession` until it can load a world and player.

Acceptance:

- The new Reality ECS files compile for visionOS.
- Current app behavior is unchanged because the new scene is not wired yet.

### Phase 5: Wire RealityMapScene On visionOS

Objective:

- Switch visionOS map loading to `RealityMapScene`.

Changes:

- In `GameSession`, create `RealityMapScene` under `#if os(visionOS)`.
- Update `visionOSApp.ImmersiveSpace` to read the typed Reality scene.
- Update the visionOS map screen to open/dismiss the immersive space without hosting Metal-era controls.
- Load:
  - world entity
  - skybox
  - BGM
  - player entity
  - tile entities
  - camera follow entity

Acceptance:

- visionOS can enter a map through `RealityMapScene`.
- Player, world, skybox, and basic camera appear.
- No shared `Core/Runtime` type is required by the new Reality path.

### Phase 6: Port Reality Object And Item Events

Objective:

- Move Reality packet reactions onto ECS data.

Changes:

- Port object spawn / move / stop / vanish to Reality ECS:
  - `MapObjectComponent(mapObject:)`
  - `GridPositionComponent(gridPosition:)`
  - `WalkingComponent(path:mapGrid:)`
- Port item spawn / vanish to `MapItemComponent`.
- Port player HP/SP and monster HP updates to `HealthPointsComponent` / `SpellPointsComponent`.
- Use `SpriteEntityManager` for object entity lookup and template reuse.

Acceptance:

- visionOS shows spawned NPCs, monsters, player updates, and dropped items.
- Reality path still does not depend on `MapSceneObject` or `MapSceneItem`.

### Phase 7: Port Reality Interaction And Movement Decisions

Objective:

- Make Reality gameplay interactions work against ECS entities.

Changes:

- Restore Reality targeted gestures:
  - tile tap
  - map object tap
  - map item tap
- Use ECS components to route:
  - monster attack
  - NPC talk
  - item pickup
  - ground movement
- Restore or adapt the pre-refactor `movePlayerToward` / lock-on behavior using Reality ECS data.
- Keep Reality controls gesture-first. Do not add thumbstick or action pad.

Acceptance:

- visionOS users can tap ground, monsters, NPCs, and items.
- Interaction code does not query Metal state or shared runtime state.

### Phase 8: Finish Reality Combat Feedback

Objective:

- Restore enough Reality-only feedback to make visionOS playable without reintroducing shared runtime data.

Changes:

- Keep combat text / damage digits as Reality ECS entities or systems.
- Keep skill effects only if they fit the Reality ECS lane cleanly.
- Port action animations through `SpriteActionComponent` and `PlaySpriteAnimationAction`.
- Keep BGM and object sound playback Reality-only.

Acceptance:

- Damage / miss feedback appears on visionOS.
- Attack, skill, pickup, sit/stand, death, and resurrection events produce expected Reality animations where supported.
- Reality path is feature-complete enough to remove the current `RealityRenderBackend`.

### Phase 9: Remove Reality Backend Compatibility Code

Objective:

- Delete the shared-backend Reality path after `RealityMapScene` owns visionOS.

Changes:

- Remove `RealityRenderBackend`.
- Remove Reality iOS/macOS ARView support.
- Remove Reality projection and hit-testing adapters that only existed for backend parity.
- Remove `MapSceneObjectComponent` and `MapSceneItemComponent` once no Reality file references them.

Acceptance:

- `rg "GameRenderBackend|MapSceneObject|MapSceneState|MapSceneItem" Packages/RagnarokGame/Sources/RagnarokGame/Reality` returns no matches.
- visionOS still builds.

### Phase 10: Introduce MetalMapScene As A Direct Owner

Objective:

- Move the current Metal path out from behind `MapScene + GameRenderBackend`.

Changes:

- Create a real `MetalMapScene` for iOS/macOS.
- Move current non-visionOS `MapScene` behavior into it.
- Let `MetalMapScene` own the Metal renderer / audio player directly.
- Remove `renderBackend` from the Metal scene constructor.
- Keep the existing shared runtime models temporarily in this phase to avoid mixing extraction with redesign.

Acceptance:

- iOS/macOS behavior remains close to current behavior.
- `MetalMapScene` no longer calls through `GameRenderBackend`.
- Reality code is not touched in this phase.

### Phase 11: Add Metal Object Runtime Classes

Objective:

- Start the Metal object-oriented redesign behind the current behavior.

Changes:

- Add Metal-only runtime types:
  - `MetalMapObject`
  - `MetalPlayerObject`
  - `MetalMonsterObject`
  - `MetalNPCObject`
  - `MetalMapItem`
  - `MetalMapObjectRegistry`
  - `MetalMapItemRegistry`
- Move identity, appearance, HP/SP, status, logical grid position, and item data out of `MapSceneState`.
- Keep adapters from current packet handlers to the new Metal objects.

Acceptance:

- Metal object and item lookup no longer goes through `MapSceneState.objects/items`.
- Nearest monster / NPC / item selection uses Metal registries.
- Existing Metal rendering may still consume adapter snapshots in this phase.

### Phase 12: Move Metal Movement And Animation Into Objects

Objective:

- Replace shared movement / animation runtime types with Metal-specific controllers.

Changes:

- Add:
  - `MetalMovementController`
  - `MetalAnimationController`
  - `MetalObjectPresentation`
- Move path replanning and current/next position sampling into `MetalMovementController`.
- Move action, direction, head direction, timing, and completion into `MetalAnimationController`.
- Update packet handlers to mutate Metal objects directly.

Acceptance:

- Metal no longer references:
  - `MapObjectMovementState`
  - `MapObjectMovementPlanner`
  - `MapObjectAnimationState`
  - `MapObjectAnimationCompletion`
- Player movement origin, camera target, and overlay anchors come from Metal objects.

### Phase 13: Rework Metal Renderer Inputs

Objective:

- Make Metal rendering consume Metal runtime objects directly.

Changes:

- Move `SpriteSnapshotBuilder` into the Metal runtime if it remains useful.
- Convert `MetalMapObject` / `MetalMapItem` into renderer-facing draw descriptions.
- Make combat text and skill effects Metal-owned:
  - `MetalCombatTextRuntime`
  - `MetalSkillEffectRuntime`
- Update Metal hit testing to use Metal object/item registries.
- Update Metal overlay projection to use Metal camera and object presentation positions.

Acceptance:

- Metal no longer references:
  - `MapSceneObject`
  - `MapSceneItem`
  - `MapSceneCombatText`
  - `MapSceneEffect`
  - `MapSceneState`
- `rg "MapSceneObject|MapSceneItem|MapSceneCombatText|MapSceneEffect|MapSceneState" Packages/RagnarokGame/Sources/RagnarokGame/Metal` returns no matches.

### Phase 14: Delete Shared Runtime And Backend Abstractions

Objective:

- Remove the old shared scene layer once both platform lanes are independent.

Changes:

- Delete or relocate all files under `Packages/RagnarokGame/Sources/RagnarokGame/Core/Runtime`.
- Delete:
  - `GameRenderBackend`
  - `GameRenderConfiguration`
  - `GameRenderEngine`
  - `MapRenderHost`
  - old shared `MapScene`
- Keep only shared utilities that are not runtime records, such as `MapGrid`, `PathFinder`, `GameObjectID`, sound tables, and effect lookup tables.

Acceptance:

- `rg "GameRenderBackend|GameRenderConfiguration|GameRenderEngine|MapRenderHost" Packages/RagnarokGame/Sources/RagnarokGame` returns no matches.
- `Packages/RagnarokGame/Sources/RagnarokGame/Core/Runtime` no longer exists.
- iOS/macOS build through Metal.
- visionOS build through Reality.

### Phase 15: Package And Dependency Cleanup

Objective:

- Reduce maintenance burden after the source split is stable.

Changes:

- Compile-gate Metal files with `#if os(iOS) || os(macOS)` where needed.
- Compile-gate Reality files with `#if os(visionOS)` where needed.
- Remove `ThumbstickView` imports from all visionOS-only files.
- Consider splitting package targets only after the source-level split is complete:
  - `RagnarokGameShared`
  - `RagnarokGameMetal`
  - `RagnarokGameReality`
  - product `RagnarokGame` can include the needed targets
- Do not start with target splitting; it will make the migration harder to validate.

Acceptance:

- Platform-specific code is isolated by file/folder and compile condition.
- The package manifest no longer suggests that Reality is supported on iOS/macOS or Metal is supported on visionOS.
- Xcode project still links `RagnarokGame` through the same public product.

## Validation Checklist

Run focused validation after each phase.

General package validation:

```bash
swift build --package-path Packages/RagnarokGame
```

iOS app validation after Metal phases:

```bash
xcodebuild -scheme RagnarokOffline -project RagnarokOffline.xcodeproj -destination 'generic/platform=iOS' build
```

macOS app validation after Metal phases:

```bash
xcodebuild -scheme RagnarokOffline -project RagnarokOffline.xcodeproj -destination 'generic/platform=macOS' build
```

visionOS app validation after Reality phases:

```bash
xcodebuild -scheme RagnarokOffline -project RagnarokOffline.xcodeproj -destination 'generic/platform=visionOS' build
```

Search checks near the end:

```bash
rg "ThumbstickView|ActionControlPadView" Packages/RagnarokGame/Sources/RagnarokGame/Reality
rg "GameRenderBackend|MapSceneObject|MapSceneState|MapSceneItem" Packages/RagnarokGame/Sources/RagnarokGame/Reality
rg "MapSceneObject|MapSceneItem|MapSceneCombatText|MapSceneEffect|MapSceneState" Packages/RagnarokGame/Sources/RagnarokGame/Metal
rg "GameRenderBackend|GameRenderConfiguration|GameRenderEngine|MapRenderHost" Packages/RagnarokGame/Sources/RagnarokGame
```

## Risks

- `767b840a^` Reality ECS predates several later features. Treat it as a structural baseline, not as a literal full revert.
- Duplicating packet handling will create two implementation lanes. That is acceptable here because reducing shared runtime coupling is the goal.
- SwiftPM package splitting too early will make the migration noisy. Prefer source-level separation first, target-level separation after behavior is stable.
- visionOS code is not covered by a plain macOS `swift build`; use an Xcode visionOS build after Reality phases.
- Existing names such as `MetalMapView` already mean "MTK hosting surface". Rename that surface before using `MetalMapView` for the full map screen.

## Completion Definition

The refactor is complete when:

- `GameSession` creates `MetalMapScene` on iOS/macOS and `RealityMapScene` on visionOS.
- Metal and Reality map views are separate.
- Reality has no thumbstick/action-pad controls.
- Reality uses Reality ECS components and systems instead of shared `Core/Runtime` scene records.
- Metal uses Metal-owned OO runtime objects instead of shared `Core/Runtime` scene records.
- `GameRenderBackend` and runtime backend switching are gone.
- `Core/Runtime/**` no longer contains shared map-scene runtime data.
