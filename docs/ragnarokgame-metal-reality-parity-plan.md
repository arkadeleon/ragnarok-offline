# RagnarokGame Metal vs Reality Backend Parity Plan

## Scope

This document compares the current Metal and Reality backends inside `Packages/RagnarokGame` and identifies the remaining feature gaps that are not yet aligned.

The goal is not to force both backends to be pixel-identical on every platform. The goal is to:

- keep one shared gameplay snapshot contract
- make backend differences explicit
- prioritize missing gameplay-visible features before cosmetic differences

## What Is Already Aligned

The major architecture split is already in place:

- both backends implement `GameRenderBackend`
- both consume the shared `MapSceneState`
- both support object and item rendering
- both support tile selection feedback
- both support hit testing
- both project overlay anchors on iOS and macOS
- both consume the shared presentation timeline for movement and sprite animation

That means the remaining work is mostly feature parity and platform integration parity, not another rendering architecture rewrite.

## Recently Completed

### Phase 1: Reality lifecycle parity

Reality lifecycle cleanup is no longer a known parity gap.

Current implementation:

- `RealityRenderBackend` now uses a shared teardown path from both `unload()` and `detach()`
- teardown cancels the pending snapshot task and clears rendered damage-effect bookkeeping
- teardown removes transient scene content from `rootEntity`, including world content, skybox, light entities, visionOS tile entities, and dynamic child entities
- teardown removes the world camera entity and resets selection visibility
- `RealityEntityCache.reset()` now cancels in-flight object/item loads and clears cached loaded entities plus template caches
- `detach()` now also removes the Reality anchor on iOS/macOS so the AR scene does not retain stale content
- `load(progress:)` now starts from a clean Reality scene state instead of layering new content on top of an earlier map

Result:

- reloading or re-entering a map should not accumulate stale Reality children under `rootEntity`
- Reality `unload()` / `detach()` behavior is now much closer to the Metal reset path

### Phase 2: Metal damage-effect rendering

Metal damage digits are no longer a known parity gap.

Current implementation:

- `MetalRenderBackend.syncFrameState(with:)` now forwards `state.damageEffects` into `MapRuntimeRenderer`
- `MapRuntimeRenderer` now owns a dedicated `MetalDamageEffectRenderer`
- the Metal effect renderer keeps effect ownership keyed by `MapDamageEffect.id`, matching the same shared-state diffing model used by Reality
- new Metal effects resolve their start position from the current presentation position when available, with a grid-position fallback if the target snapshot is not yet available
- Metal renders damage digits as world-space billboards using the existing sprite billboard shader path rather than a separate screen-space overlay system
- digit textures are generated for both numeric damage and `MISS`, with Metal-side color parity for miss, player-target damage, and non-player-target damage
- animation timing follows the shared `MapDamageEffect` timing model, including delayed multi-hit playback
- unloading the Metal world now also resets the transient damage-effect renderer state

Result:

- damage, miss, and delayed multi-hit feedback now appear on Metal
- combat feedback is much closer across Metal and Reality, even though the two backends still use different rendering primitives internally

## Confirmed Gaps

### 1. Scene ambience is not aligned

Reality currently owns several environment features that Metal does not reproduce:

- map BGM playback
- generated skybox
- Reality-specific world lighting setup

Evidence:

- `RealityRenderBackend.load(progress:)` loads BGM, creates `SkyboxEntity`, and calls `setupLighting(world:)`
- `MetalRenderBackend.load(progress:)` only loads `WorldAsset` into `MapRuntimeRenderer`

Impact:

- switching backend changes the perceived mood of the map, not just the rendering implementation
- backend choice currently changes audio behavior, which is larger than a visual fidelity difference

Priority: P1

### 2. visionOS HUD / overlay parity is missing

Overlay gauge projection exists for Metal and for Reality on iOS/macOS, but not for Reality on visionOS.

Evidence:

- `RealityRenderBackend.projector` returns `nil` on visionOS
- `MapView` only applies `MapOverlayView` on non-visionOS platforms
- `syncAndProjectOverlay()` is only compiled for iOS/macOS Reality

Impact:

- HP/SP gauge overlays are backend/platform dependent
- shared overlay state exists, but part of the product surface does not render it on visionOS

Priority: P1

### 3. visionOS camera interaction is not aligned with the other paths

The Reality path on visionOS currently supports tap interaction and pinch-style distance changes, but not the full camera controls exposed elsewhere.

Evidence:

- `MapRealityView` on visionOS only wires tile/object/item tap gestures plus `MagnifyGesture`
- `MapSceneARView` and `MapMetalView` support tap, pan rotation, elevation change, zoom, and reset behavior
- `RealityRenderBackend.updateCameraState(_:)` does not update elevation on visionOS

Impact:

- camera behavior differs materially by platform/backend combination
- the shared `MapCameraState` is not fully honored on visionOS Reality

Priority: P1

### 4. Host integration is intentionally split on visionOS, but not yet unified

On visionOS, `MapRenderHost` does not actually present the Reality scene in-place; the real rendering happens through the app's `ImmersiveSpace`.

Evidence:

- `MapRenderHost` returns `Text("Game")` for `.realityKit` on visionOS
- `visionOSApp` renders `MapRealityView(scene:)` inside `ImmersiveSpace`

Impact:

- backend hosting semantics differ by platform
- this is not necessarily a bug, but it is still a parity gap at the `RagnarokGame` module boundary

Priority: P2

## Recommended Plan

### Phase 1: Fix lifecycle parity first

Status:

- implemented

Objective:

- make backend attach/load/unload/detach behavior predictable before adding more features

Implemented changes:

- add an explicit Reality teardown path that removes world entities, skybox, light entities, tile entities, and cached object/item entities
- make `unload()` and `detach()` responsibilities match the Metal path more closely
- ensure reloading a second map cannot accumulate stale children under `rootEntity`

Acceptance:

- leaving and re-entering map scenes does not duplicate world content
- unloading a map releases transient Reality-only scene state

### Phase 2: Add Metal damage-effect rendering

Status:

- implemented

Objective:

- make combat feedback consistent across backends

Implemented changes:

- introduce a Metal-side damage-effect renderer fed from `MapSceneState.damageEffects`
- keep effect ownership keyed by `MapDamageEffect.id`, similar to Reality's diffing model
- implement the Metal path as a world-space billboard pass reusing the existing sprite billboard shader pipeline
- resolve effect anchors from backend presentation positions with a grid-position fallback when snapshots are not yet ready
- generate transient text textures for numeric damage and `MISS`

Acceptance:

- damage, miss, and delayed multi-hit feedback appear on Metal
- effect timing is close to the existing Reality behavior

### Phase 3: Align environment features

Status:

- implemented

Objective:

- stop backend choice from changing map ambience

Implemented changes:

- extracted `SkyboxConfiguration` and `angularDistance` from `SkyboxEntity.swift` into a new shared `Core/SkyboxConfiguration.swift` accessible by both backends
- added `MetalSkyboxRenderer`: renders a full-screen gradient quad as the first draw call of each frame, before ground/water/models, using a new `skyboxVertexShader` / `skyboxFragmentShader` pair that computes the three-point sky gradient (top → horizon → bottom) in the fragment shader from uniform colors
- `MapRuntimeRenderer` now owns a `MetalSkyboxRenderer` and exposes `setSkyboxConfiguration(_:)` to configure it; clearing the world asset also clears the skybox
- `MetalRenderBackend.load(progress:)` now generates a `SkyboxConfiguration` from `RSW.Light` (same logic as Reality) and passes it to the renderer after loading the world asset
- added `AVAudioPlayer`-based BGM playback to `MetalRenderBackend`: `load(progress:)` looks up the map BGM via `MP3NameTable`, loads the data from the resource manager, and starts looping playback; `unload()` and `detach()` stop the player
- lighting parameters from `RSW.Light` are already normalized into the shared `WorldLighting` struct consumed by both backends — no further normalization needed

Acceptance:

- Metal and Reality both provide map BGM
- Metal and Reality both provide a comparable sky / background treatment

### Phase 4: Close the visionOS product-surface gaps

Objective:

- decide which differences are intentional product design and which should be true parity work

Changes:

- choose the target for overlay gauges on visionOS:
  - 2D window overlay
  - 3D world-attached gauge entities
  - or explicitly unsupported, documented behavior
- choose the target camera interaction set for visionOS Reality:
  - keep zoom-only and document the difference
  - or add azimuth/reset/elevation controls using visionOS-appropriate gestures and UI affordances
- clarify whether `MapRenderHost` should become a true host on visionOS or remain a window placeholder while `ImmersiveSpace` owns rendering

Acceptance:

- visionOS behavior is intentional and documented
- no shared runtime capability appears "broken" simply because the product surface skipped wiring it

### Phase 5: Add parity validation

Objective:

- keep the two backends from drifting again

Changes:

- add a backend parity checklist for:
  - object spawn / despawn
  - movement interpolation
  - selection
  - hit testing
  - overlay gauges
  - damage digits
  - BGM
  - camera controls
  - unload / reload
- add focused smoke tests where practical
- add manual comparison captures for at least one representative field map and one indoor map

Acceptance:

- parity work can be verified feature-by-feature
- new shared runtime features require an explicit backend parity decision

## Execution Order

Recommended order:

1. Phase 4: visionOS product-surface parity decisions
2. Phase 5: validation and guardrails

Rationale:

- Phase 3 is now complete, so the remaining work is visionOS product decisions and validation
- visionOS needs product decisions as much as code changes

## Out Of Scope For This Plan

- forcing the two backends to share the same rendering internals
- rewriting Reality entity systems into the Metal path
- making the two backends visually identical at the shader/material level
- changing the current shared snapshot architecture
