# RagnarokGame MapView Rendering Refactor Implementation Plan

## Goal

Refactor the current RealityKit-bound map rendering flow into a backend-switchable architecture.

Target outcome:

- iOS and macOS default to Metal via MTKView.
- visionOS continues to use RealityKit via RealityView and ImmersiveSpace.
- MapView becomes a UI shell only.
- Gameplay runtime, rendering backend, overlay projection, and hit testing are separated.
- The migration is incremental, with each phase small enough to land safely.

## Constraints

- Do not attempt a big-bang rewrite.
- Every phase should end in a buildable or at least locally integratable state.
- visionOS immersive flow must remain intact throughout the migration.
- Do not expand RealityKit ownership inside MapScene while refactoring.

## Non-Goals

- No seamless hot-switching between render backends in the first iteration.
- No requirement for Metal and RealityKit to be pixel-identical in the first iteration.
- No full effects-system rewrite in the first iteration. Focus first on map world, characters, NPCs, items, selection feedback, and HUD.

## Target Architecture

### Layers

1. `RagnarokGameCore`
   - Gameplay runtime
   - Scene state
   - Input intents
   - Camera state
   - Pathfinding
   - Combat and interaction decisions
   - Overlay data

2. `RagnarokSceneAssets`
   - Engine-agnostic map and sprite asset loading
   - Shared input format for both RealityKit and Metal backends

3. `RagnarokGameRealityBackend`
   - Primary backend for visionOS
   - Optional fallback and comparison backend for iOS and macOS

4. `RagnarokGameMetalBackend`
   - Primary backend for iOS and macOS
   - Built on top of `RagnarokRenderers`, extended into a runtime map renderer

5. `RagnarokGameUI`
   - `MapView`
   - `MapRenderHost`
   - HUD, overlay, controls, menus

## Phase Overview

1. Phase 1: Establish the render-engine entry point and type boundaries
2. Phase 2: Extract camera state and input intent
3. Phase 3: Extract scene state models
4. Phase 4: Extract gameplay interaction and targeting logic
5. Phase 5: Extract overlay and projector interfaces
6. Phase 6: Introduce a shared world asset layer
7. Phase 7: Create the RealityKit backend shell
8. Phase 8: Move existing RealityKit responsibilities into the backend
9. Phase 9: Create the Metal backend shell
10. Phase 10: Connect static world rendering in Metal
11. Phase 11: Connect dynamic objects, hit testing, and selection in Metal
12. Phase 12: Move visionOS integration to the new backend interface
13. Phase 13: Remove legacy coupling and finalize the architecture

---

## Phase 1: Establish the Render-Engine Entry Point and Type Boundaries

### Objective

Make render-engine selection a first-class capability without changing the current runtime behavior.

### Changes

Add new types:

- `Packages/RagnarokGame/Sources/RagnarokGame/Client/Rendering/MapRenderEngine.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Client/Rendering/MapRenderConfiguration.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Client/Rendering/MapRenderHost.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Client/Rendering/MapRenderingSurface.swift`

Modify:

- `Packages/RagnarokGame/Sources/RagnarokGame/Client/Views/MapView.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Client/GameSession.swift`
- `RagnarokOffline/Settings/SettingsModel.swift`

### Deliverables

- Introduce `MapRenderEngine` with:
  - `.automatic`
  - `.metal`
  - `.realityKit`
- `MapView` stops choosing concrete render views directly and goes through `MapRenderHost`.
- Engine selection comes from a single source, either `SettingsModel` or `GameSession`.
- `.automatic` resolves to:
  - `realityKit` on visionOS
  - `metal` on iOS and macOS

### Acceptance

- Existing map behavior remains unchanged.
- iOS, macOS, and visionOS all still build.
- It is acceptable if `MapRenderHost` still routes to the old RealityKit path internally at this stage.

### Risk

- Very low.
- This phase changes only the entry point, not runtime behavior.

---

## Phase 2: Extract Camera State and Input Intent

### Objective

Move camera state and input intent out of RealityKit-specific view controllers and component mirrors.

### Changes

Add new types:

- `Packages/RagnarokGame/Sources/RagnarokGame/Engine/Runtime/MapCameraState.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Engine/Runtime/MapInputIntent.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Engine/Runtime/MapInteractionIntent.swift`

Modify:

- `Packages/RagnarokGame/Sources/RagnarokGame/Engine/Scene/MapScene.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Client/Views/MapSceneARView.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Client/Views/MapSceneRealityView.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Client/Views/MapView.swift`

### Deliverables

- Replace scattered angle and distance state with a unified `MapCameraState`.
- Double-tap reset, drag rotation, two-finger elevation, and zoom all update `MapCameraState`.
- Thumbstick movement emits movement intent rather than driving backend-owned objects directly.
- The old `MapScene` implementation may still consume these values internally for now.

### Acceptance

- Rotation, zoom, and thumbstick movement feel the same or very close to the current behavior.
- `MapSceneARView` becomes an input bridge instead of a camera owner.

### Risk

- Low.
- The main risk is interaction feel regression.

---

## Phase 3: Extract Scene State Models

### Objective

Create a true engine-agnostic scene state so gameplay can stop depending on the entity tree.

### Changes

Add new types:

- `Packages/RagnarokGame/Sources/RagnarokGame/Engine/Runtime/MapSceneState.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Engine/Runtime/MapObjectState.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Engine/Runtime/MapItemState.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Engine/Runtime/MapTransientEffect.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Engine/Runtime/MapSelectionState.swift`

Modify:

- `Packages/RagnarokGame/Sources/RagnarokGame/Engine/Scene/MapScene.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Client/GameSession.swift`

### Deliverables

- Add `state` to the map runtime, containing:
  - player state
  - other map objects
  - items
  - selected tile
  - temporary damage and effect descriptions
- Packet-driven updates write to `state` first.
- Object spawn, move, stop, vanish, skill, and item events first update the new state model.
- Existing RealityKit updates remain temporarily as a mirrored path only.

### Acceptance

- Incoming network packets keep the runtime state and the visible scene in sync.
- `GameSession` can read object and item state from the runtime instead of querying entities.

### Risk

- Low to medium.
- The main risk is state and entity-tree divergence during the transition.

---

## Phase 4: Extract Gameplay Interaction and Targeting Logic

### Objective

Move targeting, attack, pickup, talk, skill use, and movement-to-target logic onto runtime state.

### Changes

Add new types:

- `Packages/RagnarokGame/Sources/RagnarokGame/Engine/Runtime/MapInteractionResolver.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Engine/Runtime/MapTargetingService.swift`

Modify:

- `Packages/RagnarokGame/Sources/RagnarokGame/Engine/Scene/MapScene.swift`

### Deliverables

- `attackNearestMonster()` no longer scans `rootEntity.children`.
- `pickUpNearestItem()` no longer depends on `MapItemComponent`.
- `talkToNearestNPC()` no longer depends on `MapObjectComponent`.
- `movePlayerToward(...)` takes target coordinates from runtime state.
- Range checks and nearest-target selection are handled by pure Swift services.

### Acceptance

- Attack, pickup, talk, and skill target selection behave the same as the current version.
- Gameplay logic no longer requires a backend object to exist behind every target.

### Risk

- Medium.
- Any missing state synchronization will become visible here.

---

## Phase 5: Extract Overlay and Projector Interfaces

### Objective

Remove the current HUD dependency on `ARView.project` and make projection a backend capability.

### Changes

Add new types:

- `Packages/RagnarokGame/Sources/RagnarokGame/Client/Rendering/MapProjector.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Engine/Runtime/MapOverlaySnapshot.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Engine/Runtime/MapOverlayAnchor.swift`

Modify:

- `Packages/RagnarokGame/Sources/RagnarokGame/Client/Models/MapSceneOverlay.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Client/Views/MapView.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Client/Views/MapSceneARView.swift`

### Deliverables

- The runtime produces overlay anchors for:
  - player, monsters, and NPC head positions
  - HP and SP values
- The UI asks the backend projector for screen positions.
- The current `MapView.updateOverlay(arView:)` path is deleted.
- `MapSceneOverlay` becomes a pure UI model.

### Acceptance

- HP and SP bars still display correctly.
- The UI layer no longer imports `RealityKit`.

### Risk

- Medium.
- This phase directly affects HUD stability and alignment.

---

## Phase 6: Introduce a Shared World Asset Layer

### Objective

Replace direct RealityKit world construction with engine-agnostic world assets.

### Changes

Add a new package:

- `Packages/RagnarokSceneAssets/Package.swift`

Add new types:

- `Packages/RagnarokSceneAssets/Sources/RagnarokSceneAssets/MapWorldAsset.swift`
- `Packages/RagnarokSceneAssets/Sources/RagnarokSceneAssets/GroundRenderAsset.swift`
- `Packages/RagnarokSceneAssets/Sources/RagnarokSceneAssets/WaterRenderAsset.swift`
- `Packages/RagnarokSceneAssets/Sources/RagnarokSceneAssets/ModelRenderAsset.swift`
- `Packages/RagnarokSceneAssets/Sources/RagnarokSceneAssets/MapWorldAssetLoader.swift`

Modify:

- `Packages/RagnarokReality/Sources/RagnarokReality/WorldEntity.swift`
- `Packages/RagnarokGame/Package.swift`
- `Packages/RagnarokSceneAssets/Package.swift`
- `Packages/RagnarokReality/Package.swift`

### Deliverables

- `WorldResource` loads into shared assets rather than directly into RealityKit entities.
- Ground, water, and model data are all sourced through the shared asset layer.
- Both the RealityKit backend and the Metal backend consume the same `MapWorldAsset`.

### Acceptance

- The shared asset loader builds on its own.
- The existing RealityKit path can rebuild the current world scene from shared assets.

### Risk

- Medium.
- Asset shape decisions matter here, so scope must stay narrow.

---

## Phase 7: Create the RealityKit Backend Shell

### Objective

Formalize RealityKit as the first proper backend implementation behind a shared backend interface.

### Changes

Add new types:

- `Packages/RagnarokGame/Sources/RagnarokGame/Client/Rendering/MapRenderBackend.swift`
- `Packages/RagnarokGame/Sources/RagnarokGameRealityBackend/RealityKitMapBackend.swift`
- `Packages/RagnarokGame/Sources/RagnarokGameRealityBackend/RealityMapProjector.swift`
- `Packages/RagnarokGame/Sources/RagnarokGameRealityBackend/RealityMapHitTester.swift`
- `Packages/RagnarokGame/Sources/RagnarokGameRealityBackend/MapRealityView.swift`

Modify:

- `Packages/RagnarokGame/Sources/RagnarokGame/Client/Rendering/MapRenderHost.swift`
- `RagnarokOffline/App/visionOSApp.swift`

### Deliverables

- Define the backend lifecycle:
  - attach
  - detach
  - apply snapshot
  - hit test
  - project
- `MapRenderHost` can instantiate a backend from engine selection.
- visionOS starts using the new `MapRealityView` shell even if the old implementation is still wrapped internally.

### Acceptance

- visionOS can still enter the immersive map.
- `MapRenderHost` no longer knows which concrete render view it is hosting.

### Risk

- Low to medium.
- This phase formalizes boundaries more than visuals.

---

## Phase 8: Move Existing RealityKit Responsibilities into the Backend

### Objective

Move all direct RealityKit ownership out of the runtime and into `RealityKitMapBackend`.

### Changes

Add or move types:

- `Packages/RagnarokGame/Sources/RagnarokGameRealityBackend/RealityEntityCache.swift`
- `Packages/RagnarokGame/Sources/RagnarokGameRealityBackend/RealitySpriteNodeFactory.swift`
- `Packages/RagnarokGame/Sources/RagnarokGameRealityBackend/RealityTileSelectionRenderer.swift`

Modify:

- `Packages/RagnarokGame/Sources/RagnarokGame/Engine/Scene/MapScene.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Engine/Scene/SpriteEntityManager.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Engine/Scene/TileEntityManager.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Client/Views/MapSceneRealityView.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Client/Views/MapSceneARView.swift`

### Deliverables

Move the following responsibilities into the backend:

- root entity ownership
- camera entity ownership
- world and entity construction
- tile selector rendering
- RealityKit raycasting
- targeted gesture handling
- sprite entity caching

Remove from the runtime:

- entity ownership
- `SpatialTapGesture` and related gesture APIs
- `WorldCameraComponent`-bound camera control

### Acceptance

- The runtime no longer imports `RealityKit`.
- iOS, macOS, and visionOS still render through RealityKit, now via the backend.

### Risk

- Medium to high.
- This is the first real break in strong RealityKit coupling.

---

## Phase 9: Create the Metal Backend Shell

### Objective

Stand up the Metal backend lifecycle and host integration before connecting full rendering.

### Changes

Add new types:

- `Packages/RagnarokGame/Sources/RagnarokGameMetalBackend/MetalMapBackend.swift`
- `Packages/RagnarokGame/Sources/RagnarokGameMetalBackend/MapMetalView.swift`
- `Packages/RagnarokGame/Sources/RagnarokGameMetalBackend/MetalMapProjector.swift`
- `Packages/RagnarokGame/Sources/RagnarokGameMetalBackend/MetalMapHitTester.swift`
- `Packages/RagnarokGame/Sources/RagnarokGameMetalBackend/MapRuntimeRenderer.swift`

Modify:

- `RagnarokOffline/Core/MetalView.swift`
- `Packages/RagnarokRenderers/Sources/RagnarokRenderers/Core/Renderer.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Client/Rendering/MapRenderHost.swift`

### Deliverables

- `MapRenderHost` can instantiate `MetalMapBackend` on iOS and macOS.
- `MapMetalView` hosts an `MTKView`.
- The backend can attach, detach, resize, and receive snapshots.
- It is acceptable if the view still shows a blank scene at this stage, as long as the lifecycle is correct.

### Acceptance

- iOS and macOS can enter the Metal host path.
- No `RealityKit` dependency leaks back into the UI layer.

### Risk

- Low.
- This phase is about host and lifecycle stability, not rendering completeness.

---

## Phase 10: Connect Static World Rendering in Metal

### Objective

Render the static map world first: ground, water, and static models.

### Changes

Add new types:

- `Packages/RagnarokGame/Sources/RagnarokGameMetalBackend/Renderers/MapGroundRendererAdapter.swift`
- `Packages/RagnarokGame/Sources/RagnarokGameMetalBackend/Renderers/MapWaterRendererAdapter.swift`
- `Packages/RagnarokGame/Sources/RagnarokGameMetalBackend/Renderers/MapModelRendererAdapter.swift`

Modify:

- `Packages/RagnarokRenderers/Sources/RagnarokRenderers/RSWRenderer.swift`
- `Packages/RagnarokRenderers/Sources/RagnarokRenderers/Core/Camera.swift`
- `Packages/RagnarokGame/Sources/RagnarokGameMetalBackend/MapRuntimeRenderer.swift`

### Deliverables

- `MapWorldAsset` drives Metal rendering for ground, water, and static models.
- `MapCameraState` controls the Metal camera.
- Ground, water, and model positions match the current map coordinate system.

### Acceptance

- iOS and macOS can display the static world in Metal mode.
- Rotation and zoom work through the unified camera state.

### Risk

- Medium.
- Coordinate-system mismatches are the primary risk.

---

## Phase 11: Connect Dynamic Objects, Hit Testing, and Selection in Metal

### Objective

Render dynamic objects and restore the full interaction loop in the Metal backend.

### Changes

Add new types:

- `Packages/RagnarokGame/Sources/RagnarokGameMetalBackend/Renderers/SpriteBillboardRenderer.swift`
- `Packages/RagnarokGame/Sources/RagnarokGameMetalBackend/Renderers/ItemBillboardRenderer.swift`
- `Packages/RagnarokGame/Sources/RagnarokGameMetalBackend/MetalSelectionOverlayRenderer.swift`
- `Packages/RagnarokGame/Sources/RagnarokGameMetalBackend/MetalRaycaster.swift`

Modify:

- `Packages/RagnarokGame/Sources/RagnarokGameMetalBackend/MetalMapBackend.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Engine/Runtime/*`
- `Packages/RagnarokGame/Sources/RagnarokGame/Client/Views/MapView.swift`

### Deliverables

- Characters, monsters, NPCs, and items render in Metal.
- Ground click-to-move works in Metal.
- Monster, NPC, and item hit testing works in Metal.
- Tile selection feedback works in Metal.
- Overlay projection works in Metal.

### Acceptance

- iOS and macOS can complete the basic gameplay loop in Metal mode:
  - move
  - click ground
  - attack
  - pick up
  - talk
  - use skills

### Risk

- High.
- This phase closes the functional gap for the Metal backend.

---

## Phase 12: Move visionOS Integration to the New Backend Interface

### Objective

Switch the visionOS immersive path fully onto the new runtime plus backend model while keeping RealityKit as the backend.

### Changes

Modify:

- `RagnarokOffline/App/visionOSApp.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Client/Views/MapView.swift`
- `Packages/RagnarokGame/Sources/RagnarokGameRealityBackend/MapRealityView.swift`

### Deliverables

- `ImmersiveSpace` no longer depends directly on the legacy `MapSceneRealityView(scene:)` pattern.
- visionOS uses runtime plus backend composition.
- visionOS targeted interaction, magnify behavior, and camera follow remain functional.

### Acceptance

- visionOS immersive flow is fully functional through the new structure.
- visionOS shares the same runtime as iOS and macOS.

### Risk

- Medium.
- Backend lifecycle timing inside immersive flow is the main concern.

---

## Phase 13: Remove Legacy Coupling and Finalize the Architecture

### Objective

Remove temporary compatibility layers so the refactor is complete rather than partially migrated.

### Changes

Delete or rewrite:

- legacy `MapSceneARView`
- legacy `MapSceneRealityView`
- residual RealityKit API usage inside the runtime
- old-only paths in `SpriteEntityManager` and `TileEntityManager`
- the direct `RagnarokGame` dependency on `RagnarokReality`

Modify:

- `Packages/RagnarokGame/Package.swift`
- `Packages/RagnarokReality/Package.swift`
- `Packages/RagnarokRenderers/Package.swift`
- related target dependencies in the Xcode project

### Deliverables

- `RagnarokGameCore` does not import `RealityKit`.
- `RagnarokGameUI` does not import `RealityKit`.
- RealityKit exists only inside the Reality backend target.
- Metal is the default runtime backend on iOS and macOS.
- RealityKit is the default runtime backend on visionOS.

### Acceptance

- All target platforms build.
- iOS, macOS, and visionOS all run through the new structure.
- No core functionality is still silently relying on the old `MapScene` implementation.

### Risk

- Medium.
- Cleanup phases usually fail on missed dependency edges or hidden fallback paths.

---

## Implementation Decisions

The following decisions are locked for implementation unless explicitly revised later. They resolve the remaining architectural ambiguities in the phase plan.

### 1. Packaging Strategy

- Use a multi-target `Packages/RagnarokGame` package for runtime, UI, and backend implementation.
- Keep `RagnarokSceneAssets` as a separate package at `Packages/RagnarokSceneAssets`.
- The `Packages/RagnarokGame` target layout is:
  - `RagnarokGameCore`
  - `RagnarokGameUI`
  - `RagnarokGameRealityBackend`
  - `RagnarokGameMetalBackend`
  - `RagnarokGame` as an optional aggregation target for app-facing imports
- `Packages/RagnarokSceneAssets` exposes the `RagnarokSceneAssets` product and is consumed by both backend targets.
- Move the current Metal host bridge from `RagnarokOffline/Core/MetalView.swift` into `RagnarokGameMetalBackend`.

### 2. Runtime Root Type

- Keep the name `MapScene`.
- Gradually remove `RealityKit` ownership from `MapScene` until it is the runtime scene model rather than the render scene.
- Do not introduce a second permanent runtime root type for this migration.

### 3. GameSession Ownership

- `GameSession.MapPhase.loaded` should hold the runtime only.
- Render engine selection and render configuration remain separate from the phase payload.
- `MapView` and `MapRenderHost` read engine selection independently from session or settings state.

### 4. Automatic Engine Resolution

- `.automatic` always resolves by platform:
  - `realityKit` on visionOS
  - `metal` on iOS and macOS
- Before the Metal backend is feature-complete, `MapRenderHost` may temporarily satisfy a `.metal` request by routing to the legacy RealityKit implementation internally.
- That temporary routing is an implementation detail, not a change in the meaning of `.automatic`.

### 5. Backend Data Contract

- Backends receive complete render snapshots through a shared interface.
- The runtime is the single source of truth and is responsible for publishing updated snapshots.
- Backends are responsible for any internal diffing, caching, or incremental application they need.
- Do not expose a public incremental-sync protocol as part of the shared backend contract.

### 6. Camera Model Boundaries

- Shared runtime camera state is limited to:
  - `azimuth`
  - `elevation`
  - `distance`
  - `targetPosition`
- Camera configuration such as `targetOffset`, field of view, and camera bounds belongs in backend-facing configuration rather than runtime state.
- Follow smoothing remains backend-owned behavior rather than shared runtime state.

### 7. Input and Hit-Testing Semantics

- Unified interaction priority is:
  - map object
  - item
  - ground
- Each backend may use its own native hit-testing implementation.
- Each backend must translate hit results into a shared hit-test or interaction representation before handing control back to runtime or UI code.
- visionOS targeted gestures may remain an internal implementation detail of the RealityKit backend.

### 8. Overlay Scope for the First Cross-Backend Pass

- The minimum required shared overlay feature set is:
  - HP and SP gauges
  - tile or target selection feedback
  - projector support needed by the HUD
- Damage digits, cast feedback, and status icons are not required to be unified in the first backend-complete pass.

### 9. Shared World Asset Boundary

- `MapWorldAsset` includes:
  - ground render data
  - water render data
  - static model render data
  - map extents and terrain metadata needed for rendering and projection
  - lighting and sky descriptors needed to rebuild the scene in either backend
- `MapWorldAsset` does not include:
  - audio
  - tile selector presentation state
  - dynamic objects
  - HUD state
  - gameplay state

### 10. Metal Backend Completion Standard

- The first production-ready Metal backend pass may prioritize functional correctness over visual parity.
- The following must work:
  - movement
  - ground click-to-move
  - attack
  - pickup
  - talk
  - skill use
  - hit testing
  - overlay projection
- Animation nuance, damage presentation, and other polish details may lag behind RealityKit temporarily.

### 11. RealityKit on iOS and macOS

- Keep RealityKit available on iOS and macOS as a non-default backend for fallback, comparison, and debugging.
- Metal is still the default backend on iOS and macOS.
- Phase 13 removes architectural coupling to RealityKit from runtime and UI layers, but does not delete the RealityKit backend target itself.

---

## Recommended Validation After Each Phase

### Build Scope

Prefer the smallest relevant validation for each phase:

1. `swift build --package-path Packages/RagnarokGame`
2. `swift build --package-path Packages/RagnarokRenderers`
3. When `RagnarokSceneAssets` is introduced, also run `swift build --package-path Packages/RagnarokSceneAssets`
4. Validate visionOS-specific changes through the Xcode scheme and immersive path

### Runtime Checks

At minimum, verify the following after each meaningful phase:

1. The map can still load
2. Camera rotation and zoom still work
3. Thumbstick movement still works
4. Ground click-to-move still works
5. Monster, NPC, and item interaction still works
6. HUD alignment still looks correct
7. Map transitions do not leak resources

## Recommended Branching Strategy

Do not keep all of this in one long-lived branch. Split by capability:

1. `codex/map-render-host`
2. `codex/map-runtime-state`
3. `codex/map-overlay-projector`
4. `codex/map-reality-backend`
5. `codex/map-metal-backend-static`
6. `codex/map-metal-backend-dynamic`
7. `codex/map-render-cleanup`

## Recommended Sequencing Rules

Follow these rules while executing the migration:

1. Build the runtime source of truth before building the backends.
2. Extract projection before replacing overlay behavior.
3. Formalize the RealityKit backend before starting the Metal backend.
4. Render the static world in Metal before adding dynamic sprites and hit testing.
5. Temporary double-write is acceptable only during migration, and only with a single source of truth.

## Exit Criteria

The refactor is complete only when all of the following are true:

1. `MapView` does not directly depend on `ARView`, `RealityView`, or `RealityKit`
2. The runtime layer does not directly depend on `RealityKit`
3. iOS and macOS default to the Metal backend
4. visionOS defaults to the RealityKit backend
5. Movement, combat, skills, pickup, talk, hit testing, and HUD all work through both backends
6. The shared world asset layer is in place
7. Legacy strong-coupling entry points are deleted or removed from the production path
