# Implemented-Feature Fidelity Audit — RagnarokGame (Metal) vs roBrowserLegacy

## Scope

Third document in the gap series. The tracker records what is **missing**; this audit examines what is **already implemented but not implemented correctly** — behavioral and visual deviations from roBrowserLegacy in features the tracker marks ✅/🟡. Based on a static code audit on 2026-06-11; each finding cites the code that produces it.

Items already diagnosed in `ragnarokgame-metal-robrowserlegacy-alignment-plan.md` (water pass order, missing shadow pass, selective sprite depth-write, damage-digit depth, animated RSM) are not repeated.

Severity: **P0** = breaks scene correctness everywhere; **P1** = visibly wrong in common situations; **P2** = noticeable behavioral deviation; **P3** = polish/UX parity.

| # | Finding | Severity |
|---|---|---|
| F1 | Sprite depth bias in NDC makes sprites win the depth test against half the scene | P0 |
| F2 | Sprite facing ignores camera rotation | P1 |
| F3 | Spherical billboarding instead of legacy vertical billboard + depth correction | P1 |
| F4 | Sprite world scale is 1/32 instead of legacy 1/35 | P1 |
| F5 | Attack animation not time-scaled to attack speed (amotion) | P2 |
| F6 | Combat text drifts in fixed world direction, not camera-relative | P2 |
| F7 | Monster HP gauges visible from spawn; player has an overhead gauge | P2 |
| F8 | No walk fast-forward for late/bursty move packets | P2 |
| F9 | Camera constraints differ from legacy (fixed elevation, free azimuth, no snap) | P3 |

Audited and found **faithful** (no action): diagonal walk cost (`sqrt(2)` vs legacy's fixed `1.414` — 0.015% apart, both approximating the server); combat-text motion curves (parabola/scale/fade match `Effects/Damage.js` closely); action settle timing driven by `amotion` (`sourceSpeed`) for attack/skill/pickup; gauges restricted to monsters rather than all objects; per-action sounds via weapon/job tables; frame pass order skybox→ground→water→models→sprites→effects (matches legacy except the known water-order gap).

---

## F1 (P0) — Sprite depth bias: sprites render in front of models almost everywhere

**Symptom**: sprites (characters, monsters, NPCs — and combat text, which shares the pipeline) appear in front of map models that should occlude them. At default zoom it affects most of the scene; it is not an edge case.

**Where**:
- `Packages/RagnarokRendering/Sources/RagnarokShaders/Sprite/SpriteShaders.metal:38` — `clipPos.z -= 0.001 * clipPos.w;` ("Depth bias to prevent z-fighting with ground geometry")
- `Packages/RagnarokGame/Sources/RagnarokGame/Metal/MetalMapRenderer.swift:184` — `perspective(fov, aspect, 0.1, farZ)` with `farZ = max(distance * 4, 1000)`

**Mechanism**: subtracting `0.001 * w` from clip z is a constant **0.001 NDC** bias. With near = 0.1 and far ≥ 1000, NDC depth is `z_ndc ≈ 1 − 0.1/z_view`, so 0.001 of NDC corresponds to `Δ(1/z) = 0.01`. A sprite at view depth `z_s` therefore passes the depth test against any geometry at depth `z_g ≥ 1/(1/z_s + 0.01)`:

- sprite at z = 30 → beats all models closer than ~23 units in front of it
- sprite at z = 100 (the default camera distance is 100, `MapCameraState.swift`) → beats **everything from depth 50 outward**, i.e. any model in the back half of the view fails to occlude it

The bias intended to stop z-fighting with the ground at ~0 distance grows hyperbolically with view distance because it is applied in post-projection space.

**Legacy reference**: roBrowserLegacy applies no NDC bias; `SpriteRenderer.vs` does a per-vertex **view-space** depth correction for the vertical billboard plane (see F3) and otherwise lets sprites depth-test normally.

**Fix**: remove the NDC bias; replace with one of (in order of preference):
1. A small **view-space** offset before projection: move `worldPos` toward the camera by a constant ~0.05–0.1 world units (`worldPos += normalize(cameraPosition − worldPos) * bias`). Constant in world terms at every distance; kills the ground z-fighting without defeating model occlusion.
2. `renderCommandEncoder.setDepthBias(_:slopeScale:clamp:)` on the sprite draw — hardware slope-scaled bias in depth-buffer units.
3. Raise the near plane (0.1 is far closer than the camera can ever get; ~1–2 reclaims most depth precision) — worth doing regardless, but alone it only shrinks the error by ~10–20×, doesn't fix the design.

Note: fix this **before** alignment-plan Phase 4 (selective depth-write); with this bias in place, giving player sprites depth-write would stamp wrong depths over the scene and make cross-occlusion worse.

## F2 (P1) — Sprite facing ignores camera rotation

**Symptom**: rotate the camera and every entity keeps showing the sprite frame for its server direction as if the camera never moved; walking "north" shows the back view regardless of where north is on screen.

**Where**: direction-to-frame resolution uses only the entity's `SpriteDirection` (`Metal/Sprite/SpriteFrameResolver.swift`; `MetalMapObject.direction` set from packets). No code in the Metal sprite path reads `cameraState.azimuth` — it is only used for the view matrix (`MetalMapRenderer.swift:172`) and joystick input mapping (`MetalMapScene.swift:182`).

**Legacy reference**: `Renderer/Entity/EntityRender.js:237/685` — every frame lookup is `(Camera.direction + entity.direction + 8) % 8`, where `Camera.direction = round(azimuth / 45°)`. Sprite facing is camera-relative by construction.

**Fix**: add a camera direction term when resolving the action frame: `renderDirection = (spriteDirection + round(azimuth / 45°)) % 8` applied centrally in `SpriteFrameResolver` input (so body/head/gear stay consistent), refreshed when the azimuth crosses a 45° boundary. Head-direction rendering must apply the same rotation.

## F3 (P1) — Spherical billboard instead of vertical billboard with depth correction

**Symptom**: at the fixed 45° elevation, sprites lie back toward the camera; feet detach from ground contact, tall sprites lean over slopes and intersect walls behind them; ground-contact reads differently from legacy even before the missing shadow pass.

**Where**: `SpriteShaders.metal:26–33` — quad expanded along both `cameraRight` **and** `cameraUp` (full screen-facing billboard), anchored at `spriteWorldPosition`.

**Legacy reference**: `SpriteRenderer.vs` keeps sprites on a **vertical** plane (world up, rotated to camera yaw only) and compensates the depth slope per-vertex ("Vertical billboard depth correction (per-vertex), plane anchored at sprite center"), so the sprite stands upright like the original client and its depth footprint stays at the anchor column.

**Fix**: expand along `cameraRight` and **world up** `(0, 1, 0)` (after the scene's X-flip model matrix, the up the ground uses); to avoid the vertical plane z-fighting/cutting into the ground at the feet under 45° tilt, replicate legacy's per-vertex depth correction (write the anchor's depth for all vertices, or interpolate depth from the anchor rather than the tilted plane). Couples naturally with the F1 fix — do them together in one shader revision.

## F4 (P1) — Sprite scale: 1/32 world units per sprite pixel; legacy uses 1/35

**Where**: `SpriteShaders.metal:30` — `const float pixelRatio = 1.0 / 32.0;` ("1 world unit = 32 pixels").

**Legacy reference**: `SpriteRenderer.js:86` — `size = spritePixels / 175 * xSize` with `Entity.prototype.xSize = ySize = 5` (`Entity.js:553`) → **1/35** world units per sprite pixel (35 px per cell, the original client constant; the "0.5 * 35 middle of cell" comment in `SpriteRenderer.js:127` confirms).

**Effect**: every sprite is ~9.4% larger relative to the map than in legacy/original client. Subtle alone, but it compounds: feet overshoot cell bounds, gear attachment offsets (defined in ACT pixel space) land slightly off versus map geometry, and any future side-by-side validation screenshots will never line up.

**Fix**: change `pixelRatio` to `1.0 / 35.0`. Combat text and any other consumer of the sprite pipeline inherit the change; re-check `CombatTextRenderResource` scale factors (tuned values like `scale = 4` were chosen against 1/32) and the gauge overlay anchor heights.

## F5 (P2) — Attack animation speed not scaled by attack speed

**Where**: `MetalMapScene+EventHandler.swift:330–334` — the **settle** (return to idle) is correctly timed at `.milliseconds(objectAction.sourceSpeed)` (amotion), but the attack action itself plays at the ACT file's native frame delays (`SpriteFrameResolver.onceDuration`, `SpriteFrameResolver.swift:219–239`).

**Legacy reference**: `EntityAction.js`/`EntityRender.js` scale attack-action playback so the full animation spans the attack motion (`entity.attack_speed`), then freeze/settle.

**Effect**: fast attackers cut the animation mid-swing (settle fires before the swing lands visually); slow attackers finish the swing early and stand frozen until amotion elapses. Hit timing (combat text appears at `sourceSpeed`) then disagrees with the visible swing apex.

**Fix**: when starting an attack action, compute `speedScale = amotion / nativeActionDuration` and multiply frame delays in the resolver input (a per-animation `speedMultiplier` on `MetalAnimation`). Keep the settle timer as is.

## F6 (P2) — Combat text drift is world-axis-fixed

**Where**: `CombatTextRenderResource.swift:98–104` — damage digits drift `+x / −z` in world space.

**Legacy reference**: `Effects/Damage.js` drifts digits toward screen bottom-right (camera-relative).

**Effect**: with the camera rotated ~180°, damage numbers fly up-left and "into" the target instead of away. One-line fix once camera basis vectors are available to the resource (rotate the drift vector by `−azimuth`, like the joystick mapping at `MetalMapScene.swift:182`).

## F7 (P2) — Gauge visibility policy differs from legacy

**Where**: `MetalMapScene+EventHandler.swift:129–136/161–168` — every monster gets a visible HP gauge at spawn; `MetalMapScene.swift:96` — the player gets a permanent overhead HP/SP gauge.

**Legacy reference**: `EntityLife.js` shows a monster's bar only once HP information arrives from combat (`ZC_NOTIFY_MONSTER_HP` / damage), and the player character has **no** overhead bar at all (own HP lives in `BasicInfo`).

**Effect**: crowded maps render a bar over every idle mob — visually noisy and unlike the reference client. May be an intentional UX choice; decide explicitly. If keeping parity: create the gauge lazily on first HP update/attack, and gate the player overhead gauge behind a setting (default off).

## F8 (P2) — No walk fast-forward on late move packets

**Where**: `moveObject(objectID:startPosition:endPosition:)` starts each movement from the packet's `startPosition` at packet-arrival time (`MetalMapScene+EventHandler.swift:173`, `MetalMovementPlanner.replan`).

**Legacy reference**: `EntityWalk.js:203–213` estimates the path duration, compares against the walk start tick, and **fast-forwards** the interpolation (`maxFastForward` — full duration for player-like entities, one cell for others) so entities don't fall behind the server position when packets arrive late or in bursts.

**Effect**: under packet burst (map change, lots of movers) entities visibly teleport-lag: they replay movement that the server already completed, then snap on the stop packet. With the embedded in-process server latency is small, so today this shows mainly as occasional rubber-banding for NPC/mob movement.

**Fix**: `MetalMovement` already knows total duration; offset its start time by the difference between packet receipt and presumed walk start where the destination implies elapsed travel — port the `maxFastForward` rule as-is.

## F9 (P3) — Camera constraint parity

**Where**: `MapCameraState.swift` (azimuth 0, elevation fixed π/4, distance 100 default), gestures in `MetalMapView.swift` (free azimuth, pinch distance; no elevation control, no snap).

**Legacy reference**: `Renderer/Camera.js` — elevation clamped to a narrow band around −50°, zoom clamped to a range, rotation returns/snaps in 45° steps (and `Camera.direction` feeds F2), smooth interpolated return.

**Effect**: not a defect per se, but the free camera makes several fidelity issues *more* visible (F1–F3 worsen at low angles) and produces compositions the sprite art was never designed for. After F2 lands, consider clamping elevation to the legacy band and snapping azimuth to 45° increments at gesture end.

---

## Not audited deeply (candidates for a later pass)

- **PathFinder** (`Core/PathFinder.swift`) vs legacy `PathFinding.js`: both A*; tie-breaking and obstacle weights not compared — divergence only matters when the server rejects a step (client preview path may differ from server path).
- **ACT frame-delay unit conversion** in `RagnarokSprite` (legacy multiplies ACT delay by 25 ms at load): the existing sprite previews look correct, so assumed right; verify once F5 touches the timing code.
- **Login/char flow** edge cases — covered by its own alignment plan.
- **NPC dialog** multi-page text accumulation and slow-reveal behavior vs `NpcBox` — functionally complete; pacing not compared.

## Recommended fix order

1. **F1** (one shader line + choice of replacement bias) — unblocks honest evaluation of everything else; do before alignment-plan Phase 4.
2. **F3 + F4** in the same shader revision (billboard orientation, anchor depth, 1/35 scale), then re-validate combat-text tuning.
3. **F2** (camera-relative facing) — pairs with F9's azimuth snapping if adopted.
4. **F5, F6, F7, F8** independently, any order; each is small and isolated.

Validation: one crowded map (Prontera) and one model-heavy map, camera at default and rotated 180°, side-by-side with roBrowserLegacy; specifically check sprite-behind-building occlusion (F1), facing while orbiting a standing NPC (F2), and feet contact on slopes (F3).
