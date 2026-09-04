# Moving sprite animation state into the map scene

2026-09-03

## Why

The frame a sprite is showing is simulation state, but it is currently derived inside the
draw path, in `SpriteFrameResolver.resolve()`. That inversion has two visible costs today
and blocks a family of features tomorrow.

**Cost 1 — action completion is computed and thrown away.**

`SpriteFrameResolver.swift:36-44` decides that a `.once` action has finished and rolls it to
the next action type, on a **local copy** of the action:

```swift
var action = action(for: object, camera: camera)
if case .once(let nextActionType) = action.completion, ... {
    action.actionType = nextActionType
    action.elapsedTime -= duration
    action.completion = .indefinite
}
```

The object's own `action` never learns it completed, so the same decision is re-derived on
every single frame, forever. Nothing else in the scene can ask "is this monster still
attacking?" and get the right answer.

**Cost 2 — anything keyed on the frame number has to be dragged back out.**

Playing the sounds an ACT carries needs the current frame. Reaching it meant a callback
threaded through `SpriteFrameResolver` → `SpriteAssetStore` → `MapSceneRenderResources` →
`MapSceneRuntime` and back down to the object. The same trampoline would be needed again for
attack impact frames, footstep dust, and the frame a projectile launches on.

## What makes this fixable

Two facts found while planning:

- **`ComposedSprite` has no Metal in it.** The whole `RagnarokSprite` package imports only
  CoreGraphics, Foundation, os, simd and the project's own packages. The GPU half is
  `SpritePartTextures`, which already lives separately in `RagnarokGame`. `ObjectSpriteAssets`
  is literally `composedSprite` (data) + `partTextures` (Metal) — the seam is already drawn,
  both halves just happen to sit on the render side of it.
- **The camera is already scene state.** `action(for:camera:)` folds `camera.azimuth` into the
  sprite direction, and the direction picks the ACT action index, so frame resolution depends
  on the camera. `MapScene.cameraState` already exists, so moving frame resolution into the
  scene does not drag the camera anywhere new.

## Target shape

- `MapScene` owns `ComposedSprite` per object. `SpriteAssetStore` keeps only `SpritePartTextures`.
- `MapScene.update(at:)` advances the animation: resolves the effective action, computes the
  frame index, and writes `.once` completion back to `object.action`.
- A new `SpriteAnimation` on `MapSceneMapObject`, sibling to `movement` / `death` / `cast`, holds
  what is actually being shown: the resolved action type, the camera-adjusted direction, the head
  direction, the elapsed time, and the body frame index.
- `SpriteFrameResolver` reads that and builds vertices. It stops deciding anything.
- ACT frame sounds are played in `MapScene.update(at:)`, next to where map sounds already
  play, using `GameAudio.Source` with the object's world position.

The `onActionSound` callback, the `SpriteActionSound` type and `MapSceneMapObject.lastActionSound`
from the stashed work all disappear.

## Two tensions to settle first

**A. `SpriteAction` mixes intent with progress.**

`actionType` / `completion` are intent — what the object was told to do. `elapsedTime` and now
`frameIndex` are progress. Worse, `action(for:camera:)` builds a *derived* action that is not
what is stored: it overrides `actionType` to `.walk` while moving, takes `elapsedTime` from
`movement.animationElapsedTime`, and falls back to `.idle` when the job has no such action.

So "the action" means two different things depending on where you stand, and today only one of
them has a name. The fix is to give the other one a name too:

- `object.action` stays `SpriteAction`, and stays pure intent: what the object was told to do.
- `object.animation` is a new `SpriteAnimation`, rebuilt every `MapScene.update(at:)`: the
  resolved action type, the camera-adjusted direction, the head direction, the elapsed time, and
  the body frame index.

The frame index belongs to the derived value, not to the intent, so it goes in `SpriteAnimation`.
Putting it in `SpriteAction` would have meant an index that does not match the action type stored
beside it — the walk override alone breaks that pairing.

Nothing writes a derived `actionType` back into `action`, because they are now different fields.
The only thing that flows back into `action` is a resolved `.once` completion, which is a genuine
intent change.

This also lets `SpriteFrameResolver` drop `action(for:camera:)` entirely: the resolved value it
recomputes every frame is exactly what `animation` now holds.

Naming note: `SpriteAnimation` reads well against `SpriteAction`, but "action" and "animation" are
both loaded terms in ACT files. `ResolvedSpriteAction` is the more explicit alternative if the
pair turns out to be confusing in use.

**B. There is no single frame index — there is one per part.**

`frameInterval` and `frameRange` differ per part: `ComposedSprite.Part.frameRange` gives
`playerBody`, `playerHead` and `headgear` different ranges for `.idle` / `.sit`, and attack
actions scale the interval by `attackDelay`.

Decision: `SpriteAnimation.frameIndex` is **the body part's** raw index (the pre-modulo value, so
it keeps counting up across loops). It is the one that drives sounds and any future
frame-keyed logic. The renderer still derives per-part indices for drawing.

That means the arithmetic gets a second caller. When step 2 adds it, pull the shared part
(`frameRange` + `frameInterval` + raw index) into one helper next to `frameRange` on
`ComposedSprite.Part`, rather than copying it. Extracting it ahead of time was tried and
reverted — with only one caller it is pure indirection.

## Steps

Each step compiles and is reviewed on its own.

1. **Move `ComposedSprite` ownership to the scene.** Split `SpriteAssetStore` so it loads and
   holds only `SpritePartTextures`; the composed sprite is loaded into `MapScene` (keyed by
   object, invalidated by `ComposedSprite.Configuration` exactly as today). `SpriteFrameResolver`
   takes the composed sprite as a parameter instead of reading it from the store.
2. **Add `SpriteAnimation`, built in `MapScene.update(at:)`.** Move `action(for:camera:)` out of the
   resolver and store its result on the object, plus the body frame index. This is where the frame
   index arithmetic gets extracted (tension B). The renderer switches to reading `object.animation`
   instead of deriving it, and keeps computing its own per-part indices through the same helper.
   Nothing consumes `frameIndex` yet.
3. **Write `.once` completion back.** Move the roll-to-next-action out of the resolver into
   `MapScene.update(at:)`. This is the real bug fix. Audit first: anything that assumes
   `object.action.actionType` never changes on its own may need adjusting.
   *Done. The audit found nothing at risk — `.after` already changed `actionType` on its own,
   so no caller could have depended on it staying put. It also found the trap: `.after`
   rebases `startTime`, so writing the rolled-over `elapsedTime` back without rebasing would
   be undone by the next update. `.once` now lives beside `.after` in `SpriteAction.update`
   and shares that rebasing. See the two deliberate divergences below.*
4. **Play ACT frame sounds from the scene.** Recover the `soundIndex` / `act.sounds` lookup and
   `ComposedSprite.Part.isBody` from `stash@{0}`; drop the rest of that stash.
5. **Delete the dead paths.** Whatever plumbing is left over once the resolver only reads
   `object.animation`.

## Deliberate divergences from the old behavior

Both come from step 3, and both were raised in review. They are choices, not oversights.

**Action timing no longer depends on the camera.** The old code worked out how long a `.once`
action runs from the camera-adjusted direction, because it did the rollover on the derived
action. It now uses the direction the object faces in the world. Turning the camera should not
change when an attack ends. The two only differ if a sprite gives its 8 directions different
frame counts or animation speeds, which RO's ACT files do not.

**A `.once` action now expires while the object walks.** The old derived action forced
`completion` to `.indefinite` while moving, so a `.once` action survived the whole walk and
rolled over on the first frame after stopping. It now ends on schedule. On screen this is the
same — walking overrides what is drawn either way, and the old code rolled over immediately on
stopping — but `object.action` is now correct during the walk, which is the point of the step.

## Risks

- **Step 3 changes when actions end.** Today a `.once` action never resolves for an object whose
  sprite has not loaded, because the resolver only runs when there are assets. After the move,
  the scene needs the composed sprite for `onceDuration`, so the behavior stays equivalent — but
  this must be kept equivalent deliberately, not by accident.
- **Step 1 touches the sprite loading path**, which is shared by every object on the map. The
  configuration-change invalidation in `syncObject` is subtle (it cancels an in-flight load when
  the configuration changes mid-load) and must be carried over exactly.
- **Frame counts can differ per direction.** The action index is camera-dependent, so the body
  frame index is too. This is already true today; it just becomes visible once the value is
  stored.
- **`stash@{0}` will not pop cleanly** after step 1. Take the two small pieces named in step 4 by
  hand rather than popping.
