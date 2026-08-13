# Compositor Services Migration Plan (2026-08)

Replace RealityKit with Compositor Services for the visionOS game map, and remove
`RagnarokGame/Reality/`.

> Context: on 2026-07-14 the decision was to keep RealityKit and not adopt Compositor
> Services. This plan re-opens that question. The plan itself is not the decision.

## Scope

Compositor Services is needed **only for the immersive game map**.

Everything that lives in a window keeps using RealityKit through `RagnarokReality`:

- `RagnarokOffline/Files/FilePreview/RSMFilePreviewView.swift`
- `RagnarokOffline/Files/FilePreview/RSWFilePreviewView.swift`
- `RagnarokOffline/Files/FilePreview/GNDFilePreviewView.swift`
- `RagnarokOffline/MapViewer/MapViewerMapRenderingView.swift`

So the `RagnarokReality` package stays. What goes away is `RagnarokGame/Reality/`
(31 files) and `Packages/WorldCamera/`, which nothing else uses.

## What is already in place

The last four steps reshaped the rendering layer into what Compositor Services needs, so
the host can plug straight in:

| Ready | Location |
|---|---|
| `render(frame: RenderFrame)` with `views: [RenderView]` | `RagnarokRendering/Core/RenderFrame.swift` |
| `RenderCamera` (view/projection/position/azimuth/elevation) | `Core/RenderCamera.swift` |
| `RenderConfiguration` (pixel formats + `amplificationCount`) | `Core/RenderConfiguration.swift` |
| `hitTest(_ ray: Ray)` | `Core/GameCoordinateSpaceProjecting.swift` |

The Compositor Services host does not call `Renderer.makeCamera`. It builds one
`RenderCamera` per eye from `drawable.views[i]` and `deviceAnchor`, and everything below
stays as it is.

## Known gaps

None of these fire today. They all need `frame.views.count > 1`.

1. ~~**Layer routing.**~~ Settled in Phase 2 by choosing the `.shared` layout, where the
   eyes are separated by viewport rather than by slice. `render_target_array_index` would
   only be needed under `.layered`.
2. ~~**Skybox uniforms are overwritten.**~~ Fixed in Phase 1. `SkyboxRenderer` was the only
   renderer using a persistent `MTLBuffer` with `setFragmentBuffer`, so two views in one
   encoder made both skybox draws read the last view's matrices. It now uses
   `setFragmentBytes` like every other renderer.
3. ~~**Sprite depth ignores the viewport origin.**~~ Fixed in Phase 1. `SpriteShaders.metal`
   converted `in.position` to NDC by dividing by `framebufferSize` alone, so a viewport with
   a non-zero origin made the second eye compute wrong depths.
4. ~~**Sprite ray reconstruction assumes a symmetric frustum.**~~ Fixed in Phase 1. The same
   shader derived the view ray from `projectionMatrix[0][0]` and `[1][1]`, which implies
   `P[2][0] == P[2][1] == 0`; visionOS tangents are off-axis.
5. ~~**`RenderFrame.bounds` has no meaning under Compositor Services.**~~ Settled by
   Phase 0: the map no longer projects anything into point space. The field stays only for
   the RSW file preview, and the map can be handed `.zero`.

## Phases

Each phase builds and ships on its own.

### Phase 0 — Health gauges as billboard quads ✅ Done (2026-08-12)

Not gated on Compositor Services, and it applies to iOS and macOS as well. Landing it first
removed the largest HUD dependency before the migration starts.

**No new shader was needed.** `MetalCombatTextRenderer` already draws world-anchored
billboards through `SpriteVertexUniforms` and `SpriteShaders`, and `SpriteVertex` already
carries a per-vertex `color` that the fragment shader multiplies in
(`out.color = color * in.color`). With a 1×1 white texture, the existing sprite pipeline
draws solid coloured quads.

What landed:

- `Metal/Renderables/Gauge.swift` — a class holding the object's hp, maxHp, sp, maxSp,
  objectType and worldPosition, with `makeVertices()` building the bars: border, background
  and fill quads per bar, one or two bars per object, colours taken from the old `GaugeView`
  logic. Bars are 60×5 sprite pixels, of which 32 make one world unit. Rounded corners were
  dropped.
- `Metal/Renderers/GaugeRenderer.swift` — one draw per gauge, `cameraPosition.w = 0`
  so it takes ordinary depth like combat text rather than the vertical-plane depth sprites
  use, drawn just before combat text.
- Anchored at `object.worldPosition + [0, 0, -0.8]`, updated inside
  `updateObjectPresentation()` alongside the object's own position.

**Sizing decision: constant world size.** The bars now shrink with distance instead of
staying 60×6 pt. Screen-constant sizing was possible — scale the quad by distance, the same
relation `Ray.pointWidth` uses — but it has no meaning on visionOS, and fixed world size
read acceptably on iOS.

**Design note.** The plan called for a `GaugeRenderResource` mirroring
`CombatTextRenderResource`. That split was not worth keeping: the geometry is a pure
function of the state, with no texture or time-varying sample to own, so state and geometry
live in one `Gauge`. `CombatTextRenderResource` and `SpriteLayerDrawable` stay separate
because they do own GPU resources. Use that as the test when collapsing similar pairs later:
**merge the twin into the renderer or the state only when it owns nothing.**

Deleted:

- `MetalOverlayView` and `MetalOverlayState`, along with `MetalGaugeOverlay`
- `MetalSceneState.overlay` — nothing observed it once the SwiftUI overlay was gone, so the
  gauges moved onto `MetalMapScene` beside `objects` and `items`
- `MetalMapScene.syncAndProjectOverlay()`
- `project(_ worldPoint:) -> CGPoint?` from `GameCoordinateSpaceProjecting` — the gauge sync
  was its only caller, leaving `hitTest(_ ray:)` as the protocol's only requirement
- `MetalMapRenderer.lastBounds`, which only `project` read

### Phase 1 — Stereo correctness ✅ Done (2026-08-12)

Gaps 2, 3 and 4 are fixed. All three are identity transforms with a single view — a
symmetric frustum has `P[2][0] == P[2][1] == 0` and a full-target viewport has a zero
origin — so they landed ahead of any Compositor Services code.

- `SkyboxRenderResource` no longer holds an `MTLBuffer`. It offers
  `makeUniforms(projectionMatrix:viewMatrix:cameraPosition:)` and `SkyboxRenderer` passes
  the result through `setFragmentBytes`. The resource no longer needs a device, so its
  initialiser is now `init(configuration:)`.
- `SpriteShaderTypes.h` replaces `vector_float2 framebufferSize` with
  `vector_float4 viewport`, carrying the origin as well as the size.
  `SpriteShaders.metal` subtracts the origin before converting to NDC.
- The same shader now undoes the projection's shear as well as its scale:
  `(ndc.x - P[2][0]) / P[0][0]`. Derivation: `ndc.x = (P[0][0]·vx + P[2][0]·vz) / vz`,
  solved for `vx` with `vz = 1`.

Gap 1 was **not** implemented, because it depends on a layout that has not been chosen yet.

#### Layout choice

Compositor Services offers three layouts, and gap 1 exists only under one of them:

| Layout | Shape | Fits the current `render(frame:)`? |
|---|---|---|
| `.dedicated` | One texture per view | No — needs a render pass per view; today there is one encoder for all views |
| `.shared` | One texture, views separated by viewport | **Yes — this is what the code already does** |
| `.layered` | Texture array, one slice per view | No — needs `render_target_array_index` |

`render(frame:)` already loops the views over a single encoder calling `setViewport`, which
is the `.shared` shape. Choosing `.shared` makes gap 1 disappear, and makes the Phase 1 fix
for gap 3 a precondition rather than a nicety.

Going `.layered` instead would mean adding `render_target_array_index` to the output struct
of all 11 vertex shaders — a large change with no observable effect until Phase 2 runs. Its
payoff is a single pass with vertex amplification, which is a performance question best
settled once something is actually running. **Decide this at the start of Phase 2.**

### Phase 2 — CompositorServicesHost ✅ Done (2026-08-13), partly verified

The map renders in the immersive space on the visionOS simulator: terrain, models, sprites,
effects, combat text and health gauges all appear, correctly lit and correctly depth-sorted.

What landed:

- `Metal/MetalMapLayerRenderer.swift` — the frame loop, with the same job as
  `MetalMapViewController`: `startUpdate` / `prepareFrame` / `endUpdate`, sleep until
  `optimalInputTime`, `startSubmission`, set `deviceAnchor`, build one `RenderView` per eye,
  `render(frame:)`, `encodePresent`, `endSubmission`
- `Metal/MetalMapCompositorContent.swift` — the `ImmersiveSpaceContent` wrapper, the
  `CompositorLayerConfiguration`, and `RenderConfiguration.immersive`
- Depth direction reaches the renderers through `RenderConfiguration.isDepthReversed`, which
  derives `clearDepth` and `depthCompareFunction`. Compositor Services **only** supports
  reversed depth — `layer_renderer_configuration.h` says so outright.
- Scene selection (what the plan called Phase 3): the `#if os(visionOS)` branches in
  `GameSession` and `GameView` are gone, `MetalMapSceneView` opens the immersive space on
  visionOS instead of embedding an `MTKView`, and `visionOSApp` hosts
  `MetalMapCompositorContent`
- Layout is `.shared`, settling known gap 1: one texture, one viewport per eye, which is
  what `render(frame:)` already drew

#### What the plan got wrong

**The placement rides on the view matrix, not the model matrix.** "Camera semantics" below
said to fold the game camera's view matrix into the model matrix. Doing that rotates vertex
normals with the camera while the map's light direction stays in the map's own frame, so
lighting swung as the camera orbited and whole cliff faces went black. Composing it into the
view matrix instead — `viewMatrix = eyeView * worldPlacement`, with
`camera.position = worldPlacement.inverse * eyePosition` — leaves the model matrix as the
world's own transform and every downstream assumption intact.

As a result **Phase 2a was not load-bearing after all.** Sprites and tiles reach the
placement through the view matrix, which they already used. The change is still in: their
model matrix is the world transform, matching the effect shaders, and with placement off the
model matrix it computes exactly what it did before.

#### Four things that cost a run each

1. **Progressive immersion needs the drawable render context.** `ProgressiveImmersionStyle`
   fails with *"cannot present drawable: need to use drawable render context when supporting
   progressive style"*. `drawable.addRenderContext(commandBuffer:)` is visionOS 26 and up and
   wants a stencil attachment on every pipeline plus a mask draw. The immersive space is
   `.full` for now, which loses the Digital Crown immersion dial.
2. **Handedness.** `SGLMath.lookAt` is left-handed with +Z into the screen — its own comment
   says so, and `perspective` puts `clip.w = +vz`. `drawable.computeProjection` defaults to
   the `.rightUpBack` convention, where visible geometry sits at −Z. Without
   `simd_float4x4(diagonal: [1, 1, -1, 1])` on the placement the whole map sits behind the
   viewer. The symptom is exact: only the skybox draws, because it is a full-screen ray
   reconstruction with `depthCompareFunction = .always`.
3. **Near plane.** Setting `defaultDepthRange` to `[1000, 0.05]` is rejected with
   `Code=-104`, which `cp_error.h` names `unsupported_near_plane_distance`. Keep the near
   plane the compositor hands over and push only the far plane out:
   `[1000, configuration.defaultDepthRange.y]`. The far plane does need extending — one map
   cell is one metre, so a map reaches hundreds of metres.
4. **Camera distance.** `MapCameraState` defaults to 100, which frames the map through a 15°
   field of view. The headset picks the field of view, so visionOS uses 15 — the value the
   Reality path already tuned as `radius: 15`.

#### Still open

- **Colour.** With `.rgba16Float` the map renders noticeably brighter and flatter than the
  same scene on macOS. The renderers work in sRGB values throughout — textures load with
  `MTKTextureLoader.Option.SRGB: false` and lighting runs in that space — so a float target
  has the compositor read them as linear and encode a second time. The colour format is now
  `.bgra8Unorm`, matching `MTKView`. **Unverified.** If the compositor reads 8-bit unorm as
  linear too, the fallback is an sRGB encode at the end of all 11 fragment shaders, switched
  by `RenderConfiguration`.
- **Stereo.** Cannot be judged from a screenshot. Whether both eyes are right and the depth
  reads correctly needs looking at in the simulator or on device.
- **The frame loop runs on the main actor**, because `Renderer` is main-actor isolated.
  Compositor Services would rather have a thread of its own, so `waitUntilRunning()` is
  replaced with polling — otherwise a paused layer stalls the app's windows. Worth revisiting
  once there is something to measure.

### Phase 4 — Input

visionOS currently has **no input into the map at all**: tapping does nothing and the camera
cannot be orbited or zoomed, because the pan and pinch gestures live in `MetalMapView`, which
the immersive path does not use. The thumbstick and action pad in the window still work,
since they call the scene directly.

- **Hit testing.** `LayerRenderer.onSpatialEvent` gives a ray, which feeds
  `scene.hitTest(ray)`. Two things to get right: the ray arrives in the compositor's frame,
  so it needs `worldPlacement.inverse` to reach the map's frame, and `Ray.pointWidth` becomes
  a small fixed angular size rather than something derived from a viewport.
- **Camera.** `MapCameraState`'s azimuth, elevation and distance keep their meaning; they
  need some spatial gesture to drive them. See "Camera semantics" below for where the
  resulting matrix goes.

### Phase 5 — HUD (the biggest unknown)

An immersive space has no 2D canvas. Health gauges were dealt with in Phase 0. What
remains is the 7 `.overlay` modifiers in `MetalMapSceneView`: thumbstick, action pad, chat
box, menu, basic info.

Two options:

1. **Spatial controls.** Each becomes a world-space affordance in the immersive space.
2. **Keep a 2D window.** The immersive space holds only the 3D world; controls and
   information stay in a side-by-side `WindowGroup`, which the app already opens.

Option 2 is the cheaper starting point and matches how `visionOSApp` is already
structured — a `WindowGroup` beside an `ImmersiveSpace`.

**This may still be more work than the renderer itself.** Worth sizing separately before
committing to the migration.

### Phase 6 — Removal

- `Packages/RagnarokGame/Sources/RagnarokGame/Reality/` (31 files)
- `Packages/WorldCamera/` — its only importers are `RealityMapScene.swift`,
  `SpriteActionSystem.swift`, `SpriteBillboardSystem.swift` and `CombatTextSystem.swift`,
  all under `RagnarokGame/Reality/`
- `RagnarokGame/Package.swift`: the `RagnarokReality` and `WorldCamera` entries
  (lines 28, 35, 49, 56) — `RagnarokGame` stops depending on both, while the
  `RagnarokReality` package itself stays for the window content in the app target

Port the two formulas below out of `WorldCameraSystem` before deleting it.

## Camera semantics and world scale

Neither needs to be decided: a RealityKit immersive space has the same constraint as
Compositor Services — the camera is the device pose — so the Reality path already answers
both.

### Camera semantics: the game camera places the world

> Superseded in part by Phase 2: the placement composes into the **view** matrix, not the
> model matrix. Folding it into the model matrix rotates normals away from the map's light.
> The reasoning below about *where the placement comes from* still holds.

`WorldCameraSystem.update` on visionOS (`isRealityKitCamera == false`) computes the orbit
camera transform around the target and applies its **inverse** to the world root:

```swift
var targetTransform = Transform(matrix: exactCameraTransform.matrix.inverse)
worldParent.transform = targetTransform
```

The inverse of a camera's world transform is the view matrix, so the world's model
transform *is* the view matrix. The same holds under Compositor Services:

```
today:  clip = P · V · M · p
CS:     clip = P_eye · V_head · (V · M) · p
```

That is, the placement is `V`, what `MetalMapRenderer.makeCamera` produces today. The host
composes it into each eye's view matrix — `viewMatrix = eyeView · placement` — and converts
the eye position back into the map's frame with `placement.inverse`. `MapCameraState` and the
camera math stay as they are; only where the matrix is applied changes.

The placement also needs `simd_float4x4(diagonal: [1, 1, -1, 1])` in front of it, because
`lookAt` is left-handed and the compositor projects right-handed.

### World scale: one map cell is one metre

- `groundHit` reads grid positions straight out of world coordinates
  (`SIMD2<Int>(Int(x), Int(y))`), so one world unit is one map cell
- `RealityMapScene` gives `worldEntity` a rotation and **no scale**, so one world unit is
  one RealityKit unit, which is one metre
- Consistent with the sprite scale of `1.0 / 32.0`: a 32 px sprite is 1 m, putting a
  40–60 px character at 1.3–1.9 m

### What does not carry over: distance and field of view

| | distance / radius | field of view |
|---|---|---|
| Metal (`MapCameraState`, `MetalMapRenderer`) | 100, clamped 3–120 | 15° |
| Reality (`setupWorldCamera`) | 15 | RealityKit default |

The two look similar because a 15° field of view at 100 m frames about as much as a wide
one at 15 m. Compositor Services takes the field of view from the headset `tangents` and
gives the app no say, so the Metal pairing of distance 100 with a 15° field of view does
not survive. Phase 2 took the Reality path's `radius: 15`, which is already tuned for a
headset field of view. `targetOffset: [0, -0.75, 0]` has not been carried over yet.

The elevation clamp is the same on both paths (15°–60°) and carries over unchanged.

## Decisions still open

1. **HUD form.** See Phase 5. Phase 2 landed on option 2 by default — the window keeps every
   control and the immersive space holds only the map — which works, but nobody has decided
   whether that is the intended shape.
2. **Progressive immersion.** Restoring it means visionOS 26, a stencil attachment on every
   pipeline, and a mask draw. Worth it, or is full immersion the game's shape?

## Risks

- **Comfort.** Program-driven camera motion is uncomfortable in stereo. Whether the world
  moves as the character walks needs to be tried on device.
- **HUD scope is unbounded** and is the largest unknown in the plan.
- **Stereo has still not been checked.** Everything so far was judged from mono screenshots,
  which cannot show whether both eyes are right. Do this before building anything else on
  top.
- **Colour matching is unverified.** See "Still open" under Phase 2.
