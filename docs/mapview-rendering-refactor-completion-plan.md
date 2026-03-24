# MapView Rendering Refactor Completion Plan

## Purpose

This document completes the existing MapView rendering refactor plan with the missing runtime-to-backend contract needed for smooth movement, animation parity, and final removal of the temporary Reality-shaped compatibility surface.

It is intentionally narrower than the original implementation plan:

- The original plan established backend switching and the first runtime/state split.
- This document defines how to finish the transition so both Metal and RealityKit consume the same runtime snapshot model.
- The immediate trigger for this plan is the current Metal limitation where moving objects teleport between grid cells because the shared snapshot does not yet carry enough movement semantics for backend-local interpolation.

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
- New cross-backend behavior should not be added to `MapSceneRuntimeBackend`.

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

The current codebase is in an intentionally transitional state:

- `MapSceneRuntimeBackend` still exposes a command-style compatibility API for RealityKit-owned movement, lock-on scheduling, and entity mutation.
- `MetalMapBackend` consumes `MapSceneState`, but only the coarse `gridPosition` values.
- `SpriteBillboardRenderer` updates `worldPosition` directly from `gridPosition`, so movement appears as teleportation instead of interpolation.
- RealityKit still owns the only real walking lifecycle through `WalkingComponent` and related systems.

Those gaps mean the project has backend selection, but not yet a fully shared presentation contract.

## Desired End State

At the end of this follow-up work:

- `MapScene` publishes one shared render snapshot surface.
- Metal and RealityKit both consume the same movement and animation semantics.
- Both backends maintain their own presentation caches and per-frame interpolation.
- `MapSceneRuntimeBackend` is either deleted or reduced to backend lifecycle only.
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
- `startedAt: ContinuousClock.Instant`
- `duration: Duration` — summed from per-step costs; diagonal steps use `speed × √2` to match `WalkingSystem`
- `direction: CharacterDirection` — direction of the first path step

## 2. Presentation state ✅

`MapObjectState` now carries:

- `presentation: MapObjectPresentationState` — always present; initialized to `.idle/.south` on spawn

`MapObjectPresentationState` fields (as implemented):

- `action: CharacterActionType` — reuses the existing `RagnarokSprite` enum instead of a new parallel type
- `direction: CharacterDirection`
- `startedAt: ContinuousClock.Instant`
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

## 2. Metal backend

Metal should mirror the same presentation model without recreating entries each frame.

- Maintain `SpriteEntry` and any future animation state keyed by object ID.
- On snapshot apply, update desired movement/action targets.
- On each frame, evaluate interpolation from cached semantic state into renderable `worldPosition`, frame selection, and hit boxes.

The current `SpriteBillboardRenderer` already has the right lifetime model for entries; it needs richer state, not a different ownership model.

## 3. Shared runtime surface

`MapScene` should stop asking a backend for simulation-critical answers where possible.

In particular, phase out backend-owned answers for:

- `currentPlayerMovementOrigin()`
- `schedulePlayerArrivalAction(...)`
- command-style spawn/move/stop/remove hooks

Those should become runtime-state-driven decisions once the shared movement timeline exists.

## Proposed Phases

## Phase A: Define Shared Movement and Presentation Semantics ✅

### Objective

Expand the shared snapshot so both backends have enough information to render smooth motion and action changes without backend-specific command callbacks.

### Changes

New runtime types added:

- `MapObjectMovementState` — `from`, `to`, `path: [SIMD2<Int>]`, `startedAt: ContinuousClock.Instant`, `duration: Duration`, `direction: CharacterDirection`
- `MapObjectPresentationState` — `action: CharacterActionType`, `direction: CharacterDirection`, `startedAt: ContinuousClock.Instant`, `duration: Duration?`
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

## Phase B: Move Arrival and Follow-up Action Scheduling Into Runtime

### Objective

Remove gameplay dependence on backend-private walking completion.

### Changes

Modify:

- `MapScene`
- `MapInteractionResolver`
- any lock-on or arrival-action handling

### Deliverables

- Runtime can determine whether an action should fire immediately or after a movement sequence completes.
- Arrival scheduling is based on shared movement state rather than backend-owned `WalkingComponent` lifecycle.
- The runtime no longer needs `currentPlayerMovementOrigin()` or `schedulePlayerArrivalAction(...)`.

### Acceptance

- Attack, pickup, talk, and skill-follow movement continue to fire at the correct perceived time.
- Metal mode and Reality mode share the same arrival behavior.

### Risk

- High.
- This is the main place where hidden dependence on RealityKit walking behavior can still leak through.

## Phase C: Make Metal a Full Snapshot Consumer

### Objective

Upgrade the Metal backend from coarse grid-position rendering to presentation-cache-driven motion and animation.

### Changes

Modify:

- `MetalMapBackend`
- `MapRuntimeRenderer`
- `SpriteBillboardRenderer`
- related hit-testing and overlay projection paths

### Deliverables

- Metal interpolates moving objects smoothly from shared movement semantics.
- Overlay projection follows interpolated presentation positions.
- Hit testing uses current presentation bounds, not stale grid anchors.
- Initial animation parity supports at least idle, walk, and attack-facing transitions.

### Acceptance

- Player and monster movement in Metal no longer teleports between cells.
- Motion timing is visually close to RealityKit for the same snapshot input.

### Risk

- Medium.
- The main risk is drift between visual interpolation and gameplay timing if runtime timestamps are underspecified.

## Phase D: Rebase RealityKit on the Same Snapshot Semantics

### Objective

Keep RealityKit functional while removing its hidden role as the only backend with a real movement model.

### Changes

Modify:

- `RealityKitMapBackend`
- Reality-specific ECS components and systems related to walking and action playback

### Deliverables

- RealityKit entities consume the same movement/presentation semantics as Metal.
- Backend-private ECS remains an implementation detail rather than a source of truth.
- Overlay and projector paths use presentation state local to the backend.

### Acceptance

- RealityKit still feels the same to the player.
- Runtime no longer needs command-style mutation hooks to keep RealityKit visually correct.

### Risk

- Medium to high.
- RealityKit currently has the deepest hidden ownership of movement lifecycle.

## Phase E: Delete the Compatibility Surface

### Objective

Finish the refactor by removing the command-style runtime backend API.

### Changes

Delete or shrink:

- `MapSceneRuntimeBackend`
- backend mutation methods that exist only to mirror packet events into RealityKit

Modify:

- `MapScene`
- `MapRenderBackend`
- backend attach/load/applySnapshot lifecycle

### Deliverables

- `MapScene` depends only on shared runtime state plus the render-backend snapshot interface.
- Backends receive snapshots and perform internal diffing only.
- Packet handlers update runtime state once.

### Acceptance

- `MapScene` no longer issues spawn/move/remove/update commands into a backend.
- Metal and RealityKit both remain functional through the same snapshot flow.

### Risk

- Medium.
- The risk is mostly hidden one-off behavior still encoded in backend mutation methods.

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

1. shared movement and presentation semantics
2. runtime-owned arrival scheduling
3. Metal interpolation and animation consumption
4. RealityKit rebasing onto the same semantics
5. deletion of the command-style compatibility API

That order keeps the critical path honest:

- first define the shared truth
- then stop gameplay from depending on backend-private walking
- then upgrade both backends to consume the same contract
- only then delete the transitional compatibility surface

## Success Criteria

This plan is complete when all of the following are true:

- moving objects do not teleport in Metal
- RealityKit is no longer the hidden owner of walking semantics
- runtime state carries enough meaning for both backends to render smooth motion
- backends own interpolation and render caches locally
- `MapSceneRuntimeBackend` is no longer the real gameplay contract
