# MapView Rendering Refactor Completion Plan

## Purpose

This document completes the existing MapView rendering refactor plan with the missing runtime-to-backend contract needed for smooth movement, animation parity, and final removal of the temporary Reality-shaped compatibility surface.

It is intentionally narrower than the original implementation plan:

- The original plan established backend switching and the first runtime/state split.
- This document defines how to finish the transition so both Metal and RealityKit consume the same runtime snapshot model.
- The immediate trigger for this plan was the Metal limitation where moving objects teleported between grid cells because the shared snapshot did not yet carry enough movement semantics for backend-local interpolation.
- Phases C and D now close the Metal and RealityKit presentation gaps; the remaining work is primarily deletion of the temporary compatibility surface.

## Core Decision

Backends should not rebuild their render graph every frame, and the runtime should not publish per-frame interpolated positions.

The architecture should instead be:

1. Runtime publishes authoritative logical state plus presentation-driving semantics in a shared snapshot.
2. Each backend owns a long-lived presentation cache keyed by stable IDs.
3. Each backend performs per-frame interpolation and animation advancement locally from the snapshot semantics.

In other words:

- `MapSceneState` is source of truth for gameplay-visible state.
- The shared snapshot contract must be expanded to include movement and animation semantics.
- Interpolated world positions, blend factors, render entities, and GPU draw entries remain backend-owned execution state.

## Target Principles

### 1. Snapshot-first contract

- Runtime publishes complete backend-consumable snapshots.
- The shared backend contract stays snapshot-based.
- New cross-backend behavior should not be added outside `MapSceneState` and `MapRenderBackend.applySnapshot(_:)`.

### 2. Presentation data is not runtime truth

- Runtime state stores movement intent/history only as needed to describe the authoritative simulation.
- Runtime state does not store per-frame interpolated world coordinates.
- Runtime state does not store backend-specific entity handles, animation players, or renderer entries.

### 3. Backend caches are long-lived

- RealityKit keeps persistent `Entity` ownership keyed by object ID.
- Metal keeps persistent sprite/model/item entries keyed by object ID.
- Snapshot application updates those caches incrementally.
- Per-frame work derives presentation from those caches rather than reconstructing them.

### 4. Movement interpolation is backend-local

- Snapshot tells the backend what movement is happening.
- Backend decides what the object should look like at the current frame time.
- Presentation timing should be derived from shared movement timing data so Metal and Reality can match behavior closely.

## Current Gaps

The current codebase has now completed the shared presentation rebasing on both backends and removed the remaining compatibility surface:

- `MapRenderBackend` is now the only backend contract used by `MapScene`; lifecycle stays on the backend, while gameplay-visible state flows through shared snapshots.
- `MetalMapBackend` consumes shared movement and presentation semantics through backend-local presentation caches instead of coarse `gridPosition` snapshots.
- `MapRuntimeRenderer` now splits Metal presentation into three layers:
  - `SpriteBillboardSnapshotEvaluator` evaluates current presentation state from runtime snapshot semantics.
  - `SpriteBillboardAssetStore` owns composed sprite and animation-frame caching.
  - `SpriteBillboardRenderer` only renders `SpriteBillboardDrawable` values and computes hit boxes from the current presentation position.
- `RealityKitMapBackend` now consumes the same shared movement and presentation semantics through backend-local entity caches and a dedicated presentation evaluation path.
- `MapScene` now publishes snapshots directly on runtime state changes instead of mirroring spawn/move/stop/remove/update commands into RealityKit.
- One-shot damage digits now flow through shared `MapSceneState.damageEffects` data and are diffed by the RealityKit backend during snapshot application.
- `playerMovementOrigin()` still returns `movement.to` as the joystick steering origin rather than a current presentation position.
- Focused automated validation is still pending, especially for cross-backend parity and RealityKit effect timing.

The project now has one real shared presentation contract on both Metal and RealityKit. Remaining work is validation and any follow-up cleanup, not architectural compatibility removal.

## Desired End State

At the end of this follow-up work:

- `MapScene` publishes one shared render snapshot surface.
- Metal and RealityKit both consume the same movement and animation semantics.
- Both backends maintain their own presentation caches and per-frame interpolation.
- `MapSceneRuntimeBackend` is deleted.
- Packet handling updates runtime state only; backends react by consuming snapshots.

## Snapshot Contract Expansion

## 1. Movement state ✅

`MapObjectState` now carries:

- `gridPosition: SIMD2<Int>` — last authoritative logical grid position (unchanged)
- `movement: MapObjectMovementState?` — nil when stationary

`MapObjectMovementState` fields (as implemented):

- `from: SIMD2<Int>`
- `to: SIMD2<Int>`
- `path: [SIMD2<Int>]` — full resolved path from `pathfinder.findPath`; includes start position as `path[0]`
- `startTime: ContinuousClock.Instant`
- `duration: Duration` — summed from per-step costs; diagonal steps use `speed × √2` to match `WalkingSystem`
- `direction: CharacterDirection` — direction of the first path step

## 2. Presentation state ✅

`MapObjectState` now carries:

- `presentation: MapObjectPresentationState` — always present; initialized to `.idle/.south` on spawn

`MapObjectPresentationState` fields (as implemented):

- `action: CharacterActionType` — reuses the existing `RagnarokSprite` enum instead of a new parallel type
- `direction: CharacterDirection`
- `startTime: ContinuousClock.Instant`
- `duration: Duration?` — nil for open-ended states (idle, sit); set for timed actions (walk, attack)

`CharacterDirection(sourcePosition:targetPosition:)` is the shared delta-to-direction helper used by `MapScene`, `WalkingSystem`, and `SpriteEntity`.

## 3. Move camera target into shared snapshot semantics

The original implementation plan already called out `targetPosition` as shared camera state. Finish that.

- Camera target should be derived from shared runtime state rather than from backend-private walk state.
- Backend-specific camera tuning such as smoothing, target offset, FOV, and clamps should remain backend-owned.

## 4. Keep overlay as derived shared data

Overlay anchors should continue to come from snapshot data, but should be allowed to reference either:

- current interpolated backend presentation position
- or snapshot semantic position when exact presentation position is not needed

Rule of thumb:

- if a bar must visually track a moving head every frame, backend uses its presentation cache
- if a value is logical-only, runtime snapshot owns it

## Backend Responsibilities

## 1. RealityKit backend

RealityKit should stop being the hidden simulation owner for walking.

Instead:

- Maintain an `Entity` cache keyed by object ID.
- On snapshot apply, update desired presentation state for each cached entity.
- In RealityKit systems or per-frame update hooks, evaluate movement/action state into transforms and animation playback.
- Keep Reality-specific conveniences such as ECS components, follow smoothing, and targeted gesture plumbing internal.

Important consequence:

- `WalkingComponent` can still exist internally if useful, but it should be fed from snapshot semantics rather than being the only authoritative movement model.

This is now implemented as:

- persistent `Entity` ownership via `RealityEntityCache`
- snapshot-driven sync in `RealityKitMapBackend.applySnapshot(_:)`
- `MapObjectSnapshotPresentationComponent` for desired presentation state
- `MapObjectSnapshotPresentationSystem` for per-frame transform and animation timing evaluation
- overlay projection derived from backend-local presentation positions

## 2. Metal backend

Metal should mirror the same presentation model without recreating entries each frame.

- Maintain long-lived presentation caches keyed by object ID.
- On snapshot apply, update desired movement/action targets.
- On each frame, evaluate interpolation from cached semantic state into renderable `worldPosition`, frame selection, and hit boxes.

This is now implemented in the Metal path as:

- `SpriteBillboardSnapshotEvaluator` for snapshot-to-presentation evaluation
- `SpriteBillboardAssetStore` for composed-sprite and animation-frame caching
- `SpriteBillboardRenderer` for pure rendering and hit-box generation

## 3. Shared runtime surface

`MapScene` should stop asking a backend for simulation-critical answers where possible.

In particular, phase out backend-owned answers for:

- `currentPlayerMovementOrigin()`
- `schedulePlayerArrivalAction(...)`
- command-style spawn/move/stop/remove hooks

Those should become runtime-state-driven decisions once the shared movement timeline exists.

This is now partially complete:

- `currentPlayerMovementOrigin()` and `schedulePlayerArrivalAction(...)` are already gone
- command-style spawn/move/stop/remove/update hooks are already gone
- action/skill-driven damage digits now flow through shared snapshot data (`MapSceneState.damageEffects`) rather than backend callback hooks

## Proposed Phases

## Phase A: Define Shared Movement and Presentation Semantics ✅

### Objective

Expand the shared snapshot so both backends have enough information to render smooth motion and action changes without backend-specific command callbacks.

### Changes

New runtime types added:

- `MapObjectMovementState` — `from`, `to`, `path: [SIMD2<Int>]`, `startTime: ContinuousClock.Instant`, `duration: Duration`, `direction: CharacterDirection`
- `MapObjectPresentationState` — `action: CharacterActionType`, `direction: CharacterDirection`, `startTime: ContinuousClock.Instant`, `duration: Duration?`
- `CharacterDirection+Movement` — `init(sourcePosition:targetPosition:)` extension; shared by `MapScene`, `WalkingSystem`, and `SpriteEntity`

`MapObjectPresentationAction` was not introduced; `CharacterActionType` from `RagnarokSprite` covers the same cases and is already used by the rendering layer.

Modified:

- `MapObjectState` — added `movement: MapObjectMovementState?` and `presentation: MapObjectPresentationState`
- `MapScene` — updated all packet-driven event handlers; `path` is resolved via `pathfinder.findPath` so duration and initial facing reflect the actual walk, including diagonal steps (`speed × √2`)
- `MapEventHandlerProtocol` and `GameSession` — added `onMapObjectDirectionChanged` to handle `PACKET_ZC_CHANGE_DIRECTION` (was previously dropped)

### Deliverables

- Runtime records movement as semantic state, not only final grid position.
- Runtime records presentation intent using `CharacterActionType` (idle/walk/attack1/pickup/sit/…).
- Snapshot shape is sufficient for a backend to interpolate movement without reading another backend's private ECS state.
- Turn-in-place packets update `presentation.direction` immediately.

### Acceptance

- ✅ No backend-specific APIs are required to know whether an object is currently walking.
- ✅ Movement state covers the common player and monster movement cases.
- ✅ Duration matches `WalkingSystem` timing (diagonal steps cost `speed × √2` ms).
- ✅ `STOPMOVE` correctly clears movement state for the local player as well as other objects.
- ✅ `CHANGE_DIRECTION` updates facing direction without creating spurious movement state.

### Notes

- The plan suggested a custom `MapObjectPresentationAction` enum; `CharacterActionType` was used instead to avoid duplication with the existing sprite layer.
- The plan listed `facing` as the field name; the implementation uses `direction` for consistency with `MapObjectPresentationState` and `CharacterDirection`.

## Phase B: Move Arrival and Follow-up Action Scheduling Into Runtime ✅

### Objective

Remove gameplay dependence on backend-private walking completion.

### Changes (as implemented)

- `MapScene` — added `pendingArrivalAction` and `arrivalTask`; removed all calls into the transitional backend protocol for movement origin and arrival scheduling
- `MapRenderBackend` — removed `currentPlayerMovementOrigin()` and `schedulePlayerArrivalAction(...)` from the transitional backend protocol surface
- `RealityKitMapBackend` — removed both method implementations and ECS registrations
- Deleted `LockOnComponent` and `LockOnSystem`

### Deliverables

- Runtime can determine whether an action should fire immediately or after a movement sequence completes.
- Arrival scheduling is based on shared movement state rather than backend-owned `WalkingComponent` lifecycle.
- The runtime no longer needs `currentPlayerMovementOrigin()` or `schedulePlayerArrivalAction(...)`.

### Acceptance

- ✅ Attack, pickup, talk, and skill-follow movement continue to fire at the correct perceived time.
- ✅ Metal mode and Reality mode share the same arrival behavior.

### Notes

- Arrival is scheduled via `arrivalTask` in `onPlayerMoved()` using `movement.duration + 50ms`, matching the old `WalkingSystem` + `LockOnSystem` client-side timing. `onMapObjectStopped()` serves as a secondary trigger for interrupted movement.
- `playerMovementOrigin()` still returns `movement.to` as the joystick steering origin, which is the final destination rather than the current walking step. The previous implementation used `WalkingComponent.path[1]` (updated step-by-step). Phase C did add backend-local presentation position exposure on the Metal side (`presentationWorldPosition(for:)`), but `playerMovementOrigin()` itself has not yet been rebased to consume that presentation position.

### Risk

- High.
- This is the main place where hidden dependence on RealityKit walking behavior can still leak through.

## Phase C: Make Metal a Full Snapshot Consumer ✅

### Objective

Upgrade the Metal backend from coarse grid-position rendering to presentation-cache-driven motion and animation.

### Changes (as implemented)

Modified:

- `MetalMapBackend`
- `MapRuntimeRenderer`
- `SpriteBillboardRenderer`
- related hit-testing, camera targeting, and overlay projection paths

Added / split:

- `SpriteBillboardSnapshotEvaluator`
- `SpriteBillboardAssetStore`
- `SpriteBillboardSnapshot`
- `SpriteBillboardDrawable`

Implementation details:

- `MapRuntimeRenderer` now evaluates Metal presentation in three stages:
  1. `SpriteBillboardSnapshotEvaluator` converts runtime snapshot semantics into per-object Metal snapshots with interpolated `worldPosition`, resolved animation key, and animation elapsed time.
  2. `SpriteBillboardAssetStore` keeps long-lived composed-sprite and animation-frame caches, and resolves current `SpriteBillboardDrawable` values from those snapshots.
  3. `SpriteBillboardRenderer` consumes drawables only; it no longer owns movement or animation semantics.
- Movement interpolation is evaluated locally from `MapObjectMovementState` using `startTime`, `duration`, and `path`, including diagonal step timing parity with `WalkingSystem`.
- Walk animation phase advances from total movement elapsed time rather than resetting at each path-step boundary.
- Visual facing is adjusted by camera azimuth before selecting animation sheets, matching RealityKit's sprite-facing logic.
- Timed presentation fallback now preserves post-action poses where required:
  - `sit` remains seated
  - attacks and skills return to `readyToAttack` when the job supports it
  - `pickup` / `hurt` still fall back to `idle`
- `SpriteBillboardAssetStore` prefetches the current requested animation as soon as `composedSprite` finishes loading, rather than only warming `idle.south`.
- `MetalMapBackend` and `MapRuntimeRenderer` now derive camera target and overlay anchors from current presentation positions instead of logical grid positions.
- The sprite billboard shader and CPU-side hit-box computation now use the same horizontal basis, so rendered sprites and hit bounds stay aligned after the sprite-mirroring fix.

### Deliverables

- ✅ Metal interpolates moving objects smoothly from shared movement semantics.
- ✅ Overlay projection follows interpolated presentation positions.
- ✅ Hit testing uses current presentation bounds, not stale grid anchors.
- ✅ Initial animation parity supports at least idle, walk, attack-facing transitions, and correct post-action settle poses for sit / ready stance flows.

### Acceptance

- ✅ Player and monster movement in Metal no longer teleports between cells.
- ✅ Motion timing is visually close to RealityKit for the same snapshot input.
- ✅ Camera follow and overlay anchor projection read backend-local presentation positions.
- ✅ `SpriteBillboardRenderer` is now a pure renderer rather than a mixed rendering/presentation/cache owner.

### Notes

- Automated Metal-focused tests are still pending. Validation so far has been package builds plus targeted manual verification of interpolation continuity, direction selection, overlay tracking, hit testing, and post-action pose behavior.
- RealityKit was subsequently rebased onto the same shared snapshot semantics in Phase D.

### Risk

- Medium.
- The main risk is drift between visual interpolation and gameplay timing if runtime timestamps are underspecified.

## Phase D: Rebase RealityKit on the Same Snapshot Semantics ✅

### Objective

Keep RealityKit functional while removing its hidden role as the only backend with a real movement model.

### Changes (as implemented)

Modified:

- `RealityKitMapBackend`
- `MapScene`
- RealityKit-facing ECS animation systems

Added / split:

- `MapObjectPresentationEvaluator`
- `MapObjectPresentationTimeline`
- `MapObjectSnapshotPresentationComponent`
- `MapObjectSnapshotPresentationSystem`
- `SpriteAnimationTimingComponent`

Implementation details:

- `RealityKitMapBackend.applySnapshot(_:)` now treats `MapSceneState` as the authoritative input and incrementally syncs persistent entity caches for objects and items.
- RealityKit walking is no longer driven by `WalkingComponent` / `WalkingSystem`; per-frame motion and animation timing now come from shared movement and presentation semantics.
- `MapObjectPresentationEvaluator` is shared by Metal and RealityKit so both backends evaluate movement timing, settled actions, and animation elapsed time from the same runtime contract.
- `MapObjectSnapshotPresentationSystem` updates entity transforms and sprite animation timing each frame from backend-local presentation data rather than imperative movement commands.
- `SpriteActionSystem` now consumes snapshot-provided animation timing instead of owning the timing source for map-object presentation.
- Overlay anchors now follow backend-local presentation positions on RealityKit, matching the Metal architecture.
- `MapScene` now publishes snapshots directly on runtime state changes for movement, visibility, HP/SP, items, and presentation updates; the old spawn/move/stop/remove/update command mirroring path has been removed.
- At the end of Phase D, the only remaining RealityKit-specific compatibility hooks were `performMapObjectAction(...)` and `performSkill(...)`, which existed only for backend-local effect rendering such as damage digits.

### Deliverables

- ✅ RealityKit entities consume the same movement/presentation semantics as Metal.
- ✅ Backend-private ECS remains an implementation detail rather than a source of truth.
- ✅ Overlay and projector paths use presentation state local to the backend.

### Acceptance

- ✅ RealityKit still feels the same to the player for walking, facing, and basic action playback.
- ✅ Runtime no longer needs command-style spawn/move/stop/remove/update hooks to keep RealityKit visually correct.
- ✅ RealityKit and Metal now share the same movement interpolation and settled-action evaluation logic.

### Notes

- `pickup` timing is still an area to validate carefully because the snapshot path now depends on runtime presentation timing rather than `playSpriteAnimation(..., nextActionType:)`.
- Automated RealityKit-focused tests are still pending; validation so far has been package builds plus targeted runtime verification.

### Risk

- Medium.
- The main remaining risk is drift in effect-specific or one-shot animation timing, not hidden walking ownership.

## Phase E: Delete the Compatibility Surface ✅

### Objective

Finish the refactor by removing the remaining compatibility API surface.

### Changes (as implemented)

Deleted:

- `MapSceneRuntimeBackend`
- backend mutation methods that existed only for RealityKit-side effects

Modify:

- `MapScene`
- `MapRenderBackend`
- `RealityKitMapBackend`
- `MetalMapBackend`
- shared runtime effect data

State entering Phase E:

- command-style spawn/move/stop/remove/update hooks have already been deleted
- `MapSceneRuntimeBackend` currently only retains `load(progress:)`, `unload()`, `performMapObjectAction(...)`, and `performSkill(...)`
- the remaining work is to decide whether backend-local effects become shared runtime effect snapshots or stay behind a smaller dedicated effect interface

Implementation details:

- `MapRenderBackend` now owns the full backend lifecycle surface used by `MapScene`: `attach(scene:)`, `detach()`, `load(progress:)`, `unload()`, `applySnapshot(_:)`, and `hitTest(at:)`.
- `MapScene` now depends only on `MapRenderBackend` and publishes snapshots through a single `applySnapshot()` path.
- `performMapObjectAction(...)` and `performSkill(...)` were deleted; action and skill packets now update runtime state only.
- Damage digits now use shared runtime data via `MapSceneState.damageEffects`.
- `RealityKitMapBackend` diffs `damageEffects` by stable effect IDs during snapshot application and spawns one-shot damage entities from that shared surface.
- `MapDamageEffect` now carries `creationTime: ContinuousClock.Instant`, and `MapSceneState` prunes expired effects before publishing snapshots so the shared effect list does not grow without bound.
- `syncDamageEffects` reserves an effect ID before awaiting entity lookup / creation and rolls it back on failure, avoiding duplicate damage-digit rendering across overlapping snapshot tasks.
- `MetalMapBackend` now implements the same lifecycle contract directly, even though it still ignores `damageEffects`.

### Deliverables

- ✅ `MapScene` depends only on shared runtime state plus the render-backend snapshot interface.
- ✅ Backends receive snapshots and perform internal diffing only.
- ✅ Packet handlers update runtime state once.
- ✅ RealityKit one-shot damage effects are derived from shared snapshot data rather than direct backend callbacks.

### Acceptance

- ✅ `MapScene` no longer issues spawn/move/remove/update commands into a backend.
- ✅ `MapScene` no longer issues action/skill compatibility callbacks into a backend.
- ✅ Damage effects now use a dedicated shared effect surface (`MapSceneState.damageEffects`) instead of imperative backend methods.
- Metal and RealityKit both remain functional through the same snapshot flow.

### Notes

- Phase E intentionally stops at a shared runtime damage-effect surface; it does not attempt to force identical backend implementations for every future effect type.
- Metal currently leaves `damageEffects` unused. That is acceptable for this phase because the architectural goal was deleting the compatibility surface, not full cross-backend effect parity.
- `playerMovementOrigin()` is still a known follow-up item outside Phase E.

### Risk

- Low to medium.
- The main remaining risks are validation gaps and effect-parity follow-up, not hidden backend mutation APIs.

## Data Model Guidance

## Use semantic timestamps, not frame values

Do not store:

- current interpolated `worldPosition`
- current interpolation fraction
- current render frame index

Do store:

- authoritative path endpoints
- move start time
- move duration or speed
- action start time
- action kind and facing

That keeps runtime deterministic and backend-agnostic.

## Prefer monotonic time

Movement interpolation should use a monotonic time base, not wall-clock dates.

Good options:

- `ContinuousClock.Instant`
- a custom monotonic tick value captured from one shared runtime clock

Avoid depending on calendar time or per-backend ad hoc timestamps.

## Keep object identity stable

Interpolation caches only work if object identity is stable.

- Reuse `objectID` and item IDs as cache keys.
- Avoid replacing entries for unchanged IDs unless the object truly despawned.

## Validation Strategy

## 1. Runtime-level tests

Add focused tests for:

- movement state transitions
- arrival scheduling
- presentation action transitions
- snapshot derivation from packet sequences

## 2. Metal focused validation

Add validation for:

- interpolation continuity across successive movement packets
- hit-test bounds during interpolation
- overlay tracking during movement

## 3. Reality focused validation

Add validation for:

- snapshot-to-entity sync
- walking/action timing parity with the prior implementation
- target-follow camera behavior during movement

## 4. Cross-backend parity checks

Verify the same packet sequence produces approximately the same:

- movement duration
- final position
- action start timing
- facing direction

Perfect pixel parity is not required, but timing parity should be close enough that gameplay feel does not diverge by backend.

## Explicit Non-Goals

This completion plan does not require:

- rebuilding the render graph every frame
- putting backend-private interpolation results into runtime state
- deleting RealityKit-specific ECS immediately before the shared semantics exist
- exact visual parity for every effect before basic motion semantics are unified

## Recommended Order

Implement in this order:

1. shared movement and presentation semantics ✅
2. runtime-owned arrival scheduling ✅
3. Metal interpolation and animation consumption ✅
4. RealityKit rebasing onto the same semantics ✅
5. deletion of the remaining compatibility API ✅

That order keeps the critical path honest:

- first define the shared truth
- then stop gameplay from depending on backend-private walking
- then upgrade both backends to consume the same contract
- only then delete the transitional compatibility surface

## Success Criteria

This plan is now complete. All of the following are true:

- ✅ moving objects do not teleport in Metal
- ✅ RealityKit is no longer the hidden owner of walking semantics
- ✅ runtime state carries enough meaning for both backends to render smooth motion
- ✅ backends own interpolation and render caches locally
- ✅ `MapSceneRuntimeBackend` is no longer the real gameplay contract
- ✅ remaining backend-only action/skill effect hooks are deleted or replaced by an explicit shared effect surface
