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

1. **Layer routing** — reclassified, see "Layout choice" below. `RenderView` carries no
   slice index and no renderer emits `render_target_array_index`, which only matters under
   the `.layered` layout.
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

### Phase 2 — CompositorServicesHost

Start by settling the layout choice above; the sketch below assumes `.shared`.

A new host alongside `MetalView` and `MetalMapView`, with the same responsibilities:

```swift
// per frame
let frame = layerRenderer.queryNextFrame()
frame.startUpdate() / endUpdate()
let timing = frame.predictTiming()
LayerRenderer.Clock().wait(until: timing.optimalInputTime)
frame.startSubmission()
let drawable = frame.queryDrawable()
let deviceAnchor = worldTracking.queryDeviceAnchor(atTimestamp: ...)
drawable.deviceAnchor = deviceAnchor

let views = drawable.views.enumerated().map { index, view in
    RenderView(
        viewport: view.textureMap.viewport,
        camera: makeCamera(view: view, deviceAnchor: deviceAnchor)
    )
}
renderer.render(frame: RenderFrame(
    time: ..., commandBuffer: ..., renderPassDescriptor: ...,
    views: views, bounds: .zero
))
drawable.encodePresent(commandBuffer:)
frame.endSubmission()
```

`RenderConfiguration` comes from `LayerRenderer.Configuration` — typically `.rgba16Float`
plus `.depth32Float`. Compositor Services commonly uses **reversed depth**, so check
whether the existing `depthCompareFunction = .lessEqual` and `clearDepth = 1` have to flip.

Where it lives: put it in `RagnarokGame/Metal/` first. Extracting a separate
`RagnarokRenderHost` package can wait until Compositor Services is working — no need to
split packages for its own sake.

### Phase 3 — Scene selection

Drop both branches so visionOS uses `MetalMapScene`:

- `GameSession.swift:682`
- `GameView.swift:26`

Replace the `ImmersiveSpace` contents in `RagnarokOffline/App/visionOSApp.swift`:
`RealityMapView` becomes a `CompositorLayer`.

### Phase 4 — Input

- **Hit testing.** `SpatialEventGesture` / `onSpatialEvent` gives a world-space ray, which
  feeds `scene.hitTest(ray)` directly. `Ray.pointWidth` becomes a small fixed angular size.
- **Camera.** `MapCameraState`'s azimuth, elevation and distance keep their current
  meaning; only where the resulting matrix goes changes. See "Camera semantics" below.

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

### Camera semantics: fold the view matrix into the model matrix

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

That is, `modelMatrix = V · M`, where `V` and `M` are what `MetalMapRenderer.makeCamera`
and `makeWorldModelMatrix` produce today. With the head at the origin the result is
identical to the current output, so `MapCameraState` and the camera math stay as they are —
only the slot the matrix goes into changes.

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
not survive. Start from the Reality path's `radius: 15` and `targetOffset: [0, -0.75, 0]`,
which are already tuned for a headset field of view.

The elevation clamp is the same on both paths (15°–60°) and carries over unchanged.

## Decision needed before starting

**HUD form.** See Phase 5. This is the only open question left.

## Risks

- **Comfort.** Program-driven camera motion is uncomfortable in stereo. Whether the world
  moves as the character walks needs to be tried on device.
- **HUD scope is unbounded** and is the largest unknown in the plan.
- **Stereo correctness cannot be verified incrementally.** The Phase 1 fixes are identity
  transforms with a single view, so whether they are right is only known once Phase 2
  runs. Verify all four first thing after Phase 2.
- **No early validation of the Metal path on visionOS.** Window content stays on
  RealityKit, so nothing exercises the Metal renderers on that platform until Phase 2. The
  shaders do compile for visionOS today, but nothing has run.
