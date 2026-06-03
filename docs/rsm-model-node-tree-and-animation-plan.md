# RSM Model Node Tree & Animation Plan

## Scope

Replace the current pre-baked, mesh-flattened `RSMModelRenderAsset` with a node-tree representation that both backends consume directly. Metal and RealityKit each render the model by walking the tree — Metal pushes a per-node bone matrix as a uniform, RealityKit creates one entity per node and lets its scene graph compose transforms. Finally, add RSM animation playback by swapping the per-node matrix source from "cached rest pose" to "animator-evaluated pose".

End state:

- `RSMModelRenderAsset` exposes one source of truth — a node tree — and nothing else.
- Both backends render the tree directly. Neither bakes node transforms into vertex positions at any layer.
- A single `RSMModelAnimator` evaluates per-node poses. Static models trivially fall through to default values; animated models interpolate keyframes. There is no "is animated" code path.
- Rendered output for animated RSM models matches the behavior the current implementation would produce if extended directly (rotation/position/scale keyframes per node, plus legacy v1.x root-level position keyframes).

## Why

The current pipeline bakes every node's `worldTransform` into vertex positions at asset construction. That works for static rendering but means:

- node identity is lost after compilation,
- adding animation forces a second, parallel representation (flat arrays, parent indices, topological sort),
- RealityKit ends up with one merged mesh that cannot express per-node animation at all.

A node-tree asset that both backends render directly removes the duplication. Compilation, RealityKit construction, and Metal animation all become traversals of the same tree. Static vs animated stops being a render-path fork and becomes "the animator returns defaults vs interpolated values" — a data-level distinction, not a code-level one.

## Non-Goals

- No changes to RSM file format types beyond what is already in place (`RSM.frameRatePerSecond` and `RSM.Node.PositionKeyframe.init(frame:position:data:)` exist on the current branch).
- No changes to static rendering output. Static models must render byte-equivalent to today's output after Phase 1, and pixel-equivalent after Phases 2 and 3.
- No changes to camera, lighting, water, ground, or sprite rendering.
- No RealityKit support for keyframe animation in this plan. Both geometry animation (Phase 4) and texture animation (Phase 5) are Metal-only. visionOS renders animated models at their rest pose. Driving per-frame entity transforms through a RealityKit `System` is feasible but adds a per-frame component-iteration cost and a second code path; deferring it until the Metal path is shipped lets us decide whether visionOS animation is worth the cost based on actual content.

## Current State Snapshot

Files to be touched and their roles today:

- `Packages/RagnarokRendering/Sources/RagnarokRenderAssets/RSMModel/RSMModelRenderAsset.swift`
  - `RSMModelRenderAsset` struct with `meshes: [RSMModelMesh]` (pre-baked).
  - `RSMModelNodeWrapper` (file-private class) builds the hierarchy and runs `prepareTransforms()`.
  - `compile(...)` flattens each node's geometry into pre-transformed `[ModelVertex]` arrays keyed by texture.
- `Packages/RagnarokRendering/Sources/RagnarokMetalRendering/RSMModelRenderResource.swift`
  - Creates one Metal vertex buffer per pre-baked mesh.
- `Packages/RagnarokRendering/Sources/RagnarokMetalRendering/RSMModelRenderer.swift`
  - Single pipeline, draws each mesh once per instance.
- `Packages/RagnarokRendering/Sources/RagnarokRealityRendering/RSMModelEntity.swift`
  - Creates a single `Entity` with one combined `MeshResource` concatenating every node's pre-baked mesh.
- `Packages/RagnarokRendering/Sources/RagnarokShaders/Model/ModelShaders.metal` and `ModelShaderTypes.h`
  - `modelVertexShader`, `ModelVertex`, `ModelVertexUniforms`, `ModelInstanceUniforms`, `ModelFragmentUniforms`.

External consumers of `RSMModelRenderAsset`:

- `RSMModelRenderResource.init(...)` reads `asset.meshes` (Metal).
- `Entity.init(from: RSMModelRenderAsset)` in `RSMModelEntity.swift` reads `asset.meshes` (RealityKit).
- `RSMModelEntity.swift` reads `asset.boundingBox.range.max()` for a normalizing scale.
- `WorldAssetLoader.swift` constructs `RSMModelRenderAsset` and groups instances.

These are the only API surfaces to preserve through the refactor.

---

## Phase 1 — Asset Gains a Node Tree (additive)

Goal: introduce the node-tree data model on `RSMModelRenderAsset` without changing anything either backend renders. The flat `meshes` array stays in place during this phase; both backends continue to consume it. The new tree is the single source from which the flat array is derived.

### 1.1 New types

In the same file as `RSMModelRenderAsset`:

```swift
public final class RSMModelNode: Sendable {
    public let index: Int                  // DFS order; nodes[i].index == i
    public let name: String
    public weak var parent: RSMModelNode?
    public let children: [RSMModelNode]

    // Source geometry (untransformed).
    public let vertices: [SIMD3<Float>]
    public let tvertices: [RSM.Node.TextureVertex]
    public let faces: [RSM.Face]
    public let textures: [String]

    // Rest-pose inputs.
    public let position: SIMD3<Float>
    public let rotationAngle: Float
    public let rotationAxis: SIMD3<Float>
    public let scale: SIMD3<Float>
    public let offset: SIMD3<Float>
    public let transformMatrix: simd_float3x3

    // Animation tracks (may be empty).
    public let positionKeyframes: [RSM.Node.PositionKeyframe]
    public let rotationKeyframes: [RSM.Node.RotationKeyframe]
    public let scaleKeyframes: [RSM.Node.ScaleKeyframe]

    // Compiled node-local geometry (one entry per texture used by this node).
    public let meshes: [RSMModelNodeMesh]
}

public struct RSMModelNodeMesh: Sendable {
    public let textureName: String
    public let vertices: [ModelVertex]      // node-local coordinates
}
```

`RSMModelRenderAsset` gains:

```swift
public let rootNode: RSMModelNode?
public let nodes: [RSMModelNode]            // DFS order
public let centerCorrection: SIMD3<Float>
public let animationLength: Int32
public let frameRatePerSecond: Float
public let shadeType: Int32
public let alpha: UInt8
```

It keeps for now:

```swift
public let meshes: [RSMModelMesh]           // unchanged shape; derived from the tree
public let boundingBox: RSMModelBoundingBox
public let instance: RSMModelInstance
public let lighting: WorldLighting
public let textureImages: [String : CGImage]
```

### 1.2 Construction

Rewrite `RSMModelRenderAsset.init` to build the tree first, then derive everything else from it:

1. Parse all `rsm.nodes` into temporary mutable holders keyed by name.
2. Wire parent/child references by name, skipping self-parented nodes.
3. Merge `rsm.positionKeyframes` (legacy v1.x root-level keyframes) into the root node's `positionKeyframes`, then sort by `frame`.
4. Recurse from the root computing each node's rest-pose `transformForChildren` and `transform` and accumulating its bounding box from raw vertices using its live world transform. This is the same logic `prepareTransforms()` runs today; rewrite it as a free function or static method over the new node holder to drop the file-private wrapper class.
5. DFS-walk from the root assigning `index` and appending to `nodes: [RSMModelNode]`. Nodes unreachable from the root (extremely rare; defensive) get appended at the end.
6. Compile each node's `meshes` from its raw vertices/faces in node-local space (`positionMatrix = identity`, `normalMatrix = identity`). Reuse today's `calcNormal_NONE/FLAT/SMOOTH` and `generate_mesh_FLAT/SMOOTH` logic — just call them with identity matrices.
7. Compute `boundingBox` (union across nodes) and `centerCorrection = SIMD3<Float>(-bb.center.x, -bb.max.y, -bb.center.z)`.
8. Derive the legacy `meshes: [RSMModelMesh]` array by walking the tree: for each node, multiply each node-local `ModelVertex.position` by `T(centerCorrection) * worldTransformAtRest(node)` and each `ModelVertex.normal` by `extractRotation(...)`. Emit one `RSMModelMesh` per `(node, texture)` so the existing flat shape is preserved.

`worldTransformAtRest(node)` is what `prepareTransforms()` produces today: `parent.worldTransformForChildren × (T(position) × R(rotationAngle, rotationAxis or rotationKeyframes[0].quaternion if present) × S(scale) × T(offset) × mat3)`.

The `RSMModelNodeWrapper` file-private class goes away.

### 1.3 Backend consumers

No change. `RSMModelRenderResource` and `RSMModelEntity` keep consuming `asset.meshes`.

### 1.4 Acceptance criteria for Phase 1

- `swift build --package-path Packages/RagnarokRendering` succeeds.
- `swift build --package-path Packages/RagnarokGame` succeeds.
- Static RSW/RSM file preview on iOS, macOS, and visionOS renders byte-equivalent to before. Spot-check by loading several known-static maps in each preview.
- Diff the bytes of the derived `meshes` against a captured baseline from the current main to confirm equivalence (one-shot verification step; doesn't need to live in tests).

This phase is pure refactor. Risk is contained because the public API on `RSMModelRenderAsset` only gains members.

---

## Phase 2 — Metal Renders by Walking the Tree

Goal: Metal stops consuming `asset.meshes`. The renderer walks `asset.nodes`, pushes a per-node bone matrix as a uniform, and draws each node's node-local meshes. Static models use a cached rest-pose bone matrix per node. RealityKit is untouched in this phase.

### 2.1 Shader changes

In `ModelShaderTypes.h`:

```c
typedef struct {
    matrix_float4x4 boneMatrix;
    matrix_float3x3 boneNormalMatrix;
} ModelBoneUniforms;
```

In `ModelShaders.metal`, update `modelVertexShader` to take an additional `constant ModelBoneUniforms &bone [[buffer(3)]]` and apply it:

```metal
out.position = projection × view × model × instance.modelMatrix
             × bone.boneMatrix × float4(in.position, 1.0);

float3 worldNormal = normalize(
    uniforms.normalMatrix × instance.normalMatrix
    × bone.boneNormalMatrix × in.normal);
```

`modelFragmentShader` is unchanged. There is only one vertex shader after this phase — there is no separate "animated" variant because every node, animated or not, is rendered with a bone matrix. A static node simply gets its rest-pose matrix every frame.

### 2.2 Resource changes

Rewrite `RSMModelRenderResource`:

- Drop the `MeshResource` flat list.
- Build a per-node structure: `[(nodeIndex: Int, meshes: [(vertexBuffer, vertexCount, texture)])]`. Each `vertexBuffer` is uploaded from `RSMModelNodeMesh.vertices` directly (node-local, no transform applied).
- Compute and cache `restPoseBoneMatrices: [ModelBoneUniforms]` indexed by node index:
  ```
  restPoseBoneMatrices[i] = ModelBoneUniforms(
      boneMatrix:       T(centerCorrection) × worldTransformAtRest(asset.nodes[i]),
      boneNormalMatrix: simd_float3x3(boneMatrix).inverse.transpose
  )
  ```
  Compute this once at resource construction by walking the tree top-down (parents first; the asset's `nodes` array is already DFS-ordered so a single forward sweep works).
- Keep the existing `instanceBuffer` and `light` fields as they are.

### 2.3 Renderer changes

Rewrite `RSMModelRenderer.render(...)`:

- Single pipeline (the updated `modelVertexShader` above). Drop any notion of a second pipeline.
- For each resource:
  1. Bind `ModelVertexUniforms`, instance buffer, `ModelFragmentUniforms` once.
  2. For each `nodeIndex` in the resource:
     - `var bone = resource.restPoseBoneMatrices[nodeIndex]` (Phase 4 replaces this with an animator call when keyframes exist).
     - `setVertexBytes(&bone, length: stride, index: 3)`.
     - For each `(vertexBuffer, count, texture)` on that node: bind, set texture, `drawPrimitives`.

### 2.4 Acceptance criteria for Phase 2

- Static RSW/RSM file preview on iOS and macOS renders pixel-equivalent to Phase 1 output. Sample several maps, including ones with many small RSM objects.
- visionOS preview is unchanged (RealityKit still consumes `asset.meshes`).
- Metal debug capture shows one pipeline state across all RSM draws.
- `swift build --package-path Packages/RagnarokRendering` and `swift build --package-path Packages/RagnarokGame` succeed.

Draw call count is the same as before: each node's `compile()` already produces one entry per texture, so total draws = sum over nodes of distinct textures — identical to today's flat layout.

---

## Phase 3 — RealityKit Renders an Entity Tree, Legacy `meshes` Removed

Goal: RealityKit walks the node tree, creating one `Entity` per node. The asset's legacy `meshes: [RSMModelMesh]` is removed because both backends now read the tree.

### 3.1 Entity tree construction

Rewrite `Entity.init(from: RSMModelRenderAsset)`:

1. Build the `[String : TextureResource]` map the same way as today.
2. Create a root container `Entity` with `name = modelAsset.name`. Set its `transform`:
   - `transform.translation = modelAsset.centerCorrection`
   - `transform.scale = SIMD3(repeating: 2 / modelAsset.boundingBox.range.max())`
3. Recursively walk `modelAsset.rootNode`, producing one child `Entity` per `RSMModelNode`:
   - `transform.matrix = restPoseLocalMatrix(node)` where `restPoseLocalMatrix(node) = T(position) × R(rotationAngle, rotationAxis or rotationKeyframes[0].quaternion if present) × S(scale) × T(offset) × mat3`. Phase 4 replaces this per-frame for animated nodes.
   - If the node has any `meshes`, build a `MeshResource` from `node.meshes` (node-local coords) the same way the current code builds a per-mesh descriptor. Materials per `RSMModelNodeMesh` match what the current code emits per flat `RSMModelMesh`.
   - Attach `ModelComponent(mesh:materials:)` only when there is geometry. Empty interior nodes still exist as pure transform parents.
   - Recurse into `node.children`, parenting each new entity to the current one.

The single-mesh "concatenate everything" path is gone.

### 3.2 Asset cleanup

- Remove `meshes: [RSMModelMesh]` from `RSMModelRenderAsset`.
- Remove `RSMModelMesh` type if nothing else references it (grep across `RagnarokRendering` and the app target).
- Remove the rest-pose baking code path in `RSMModelRenderAsset.init` that produced the flat list.
- `asset.boundingBox` stays — RealityKit still uses it for the root-level normalizing scale.

### 3.3 Acceptance criteria for Phase 3

- visionOS file preview of RSM and RSW models renders identically to Phase 2 output. Spot-check several static maps.
- The entity tree under an RSM root entity mirrors the RSM hierarchy 1:1 (verify via `Entity.children` count and node names).
- `swift build` clean across packages.
- No remaining references to `RSMModelMesh` in the workspace (grep).

This phase is the riskiest visually because the RealityKit composition strategy changes. Mitigation: the per-node `transform.matrix` is exactly the same matrix the current code bakes into vertices (composed via the scene graph instead of pre-applied), so rendered output should match.

---

## Phase 4 — Animation Playback (Metal only)

Goal: per-node keyframes drive per-frame poses on Metal. Animated maps animate on iOS and macOS; static maps render unchanged. visionOS continues rendering animated models at their rest pose (Phase 3 already wires `transform.matrix = restPoseLocalMatrix(node)` for every per-node entity, which is the correct "frame 0" pose).

### 4.1 Shared animator

Add `Packages/RagnarokRendering/Sources/RagnarokRenderAssets/RSMModel/RSMModelAnimator.swift`:

```swift
public struct RSMModelAnimator: Sendable {
    public init(asset: RSMModelRenderAsset)

    /// (time * fps) mod animationLength, clamped to a non-negative value.
    public static func frame(at time: CFTimeInterval, asset: RSMModelRenderAsset) -> Float

    /// T(animatedPos) × R(animatedRot) × S(animatedScale), falling back to defaults
    /// when a track is empty.
    public func localTransform(for node: RSMModelNode, atFrame frame: Float) -> simd_float4x4

    /// T(centerCorrection) × worldTransformForChildren(parent)
    ///   × (localTransform(node) × T(offset) × mat3)
    public func boneMatrix(for node: RSMModelNode, atFrame frame: Float) -> simd_float4x4
}
```

- Position keyframes: linear interpolation; default `node.position`.
- Rotation keyframes: `simd_slerp`; default `simd_quatf(angle: node.rotationAngle, axis: node.rotationAxis)`. If exactly one rotation keyframe exists, use it directly.
- Scale keyframes: linear interpolation; default `node.scale`.
- The animator may cache per-frame parent world transforms internally so a tree traversal computes all bone matrices in one pass; concrete shape is an implementation detail.

`frame(at:asset:)` uses `fps = max(asset.frameRatePerSecond, 1)` and `length = max(asset.animationLength, 1)`. This matches the RSM loader's existing unit convention (v2.2+ files pre-multiply `animationLength` by `fps`; v1.x defaults `frameRatePerSecond` to `1000`, putting both in millisecond units).

Whether a model "has animation" is a property of its data — if every node's keyframe arrays are empty, the animator returns defaults and produces matrices equal to the cached rest-pose matrices. No "is animated" flag exists at the API level. A renderer is free to short-circuit the animator call when it knows the data is static (an optimization, covered in 4.2 and 4.3).

### 4.2 Metal wiring

In `RSMModelRenderResource`:

- Add `let hasAnyKeyframes: Bool` derived once from the asset.
- Keep `restPoseBoneMatrices` (used as the fast path for static models).

In `RSMModelRenderer.render(...)`:

- For each resource:
  - If `resource.hasAnyKeyframes`: build a `RSMModelAnimator`, compute `frame`, evaluate `[ModelBoneUniforms]` for all nodes once. Use this array instead of `restPoseBoneMatrices`.
  - Otherwise: use `restPoseBoneMatrices` directly (no animator call, no per-frame work).
- The per-node draw loop is unchanged from Phase 2; only the bone-matrix source switches.

No shader changes, no second pipeline, no new uniforms — the entire animation feature on the Metal side is an `if` around the matrix source.

### 4.3 RealityKit — explicit no-op

RealityKit `RSMModelEntity` from Phase 3 already sets each per-node `Entity.transform.matrix = restPoseLocalMatrix(node)`. That is the correct frame-0 pose: identical to what the current implementation bakes today. No code change is required for visionOS in this phase.

Document this intent in `RSMModelEntity.swift` with a one-line comment near where the per-node transform is set, so a future visionOS-animation phase has an obvious hook point.

### 4.4 Acceptance criteria for Phase 4

- `prt_castle` (or another known-animated map) shows animated objects moving on iOS and macOS.
- visionOS renders the same map with animated objects frozen at their rest pose — identical to Phase 3 output for that map.
- Static maps show no per-frame difference vs Phase 3 on any platform.
- Confirm via Instruments / debug capture that static Metal resources do not allocate animator objects per frame.
- `swift build` clean across packages.

---

## Phase 5 — Texture Animation (Metal only)

Goal: animate per-(node, texture) UV transforms from `RSM.Node.TextureKeyframeGroup` data. RealityKit is intentionally left out — it keeps showing the rest-frame UVs until a future phase decides whether to take the `CustomMaterial` cost.

### 5.1 Track semantics

Each `RSM.Node.TextureKeyframeGroup` targets one of the node's textures (`textureIndex`). For that texture it carries multiple `TextureAnimation` tracks, each tagged with a `type` field. The encoding follows the convention used by other RO clients:

| `type` | Meaning |
|---|---|
| 0 | Translate U |
| 1 | Translate V |
| 2 | Scale U |
| 3 | Scale V |
| 4 | Rotation (radians) |
| 5 | Pivot U (center for scale/rotation) |
| 6 | Pivot V |

Each track's keyframes are `(frame: Int32, offset: Float)` and interpolate linearly between consecutive keyframes (same convention as the geometry tracks). Tracks that aren't present default to: translate = 0, scale = 1, rotation = 0, pivot = 0.

The composed UV matrix applied to each `(u, v)` before sampling is:

```
M_uv = T(pivot) * R(rotation) * S(scaleU, scaleV) * T(-pivot) * T(translateU, translateV)
```

Implementation note: the exact composition order needs a sanity pass against a known-affected map during implementation (Gravity's docs aren't public; the table above is the community-consensus encoding). Build a small visual comparison harness once Phase 5 starts.

### 5.2 Asset data

Add to `RSMModelNode`:

```swift
public struct RSMTextureAnimationTrack: Sendable {
    public let type: Int32
    public let keyframes: [RSM.Node.TextureAnimationKeyframe]
}

public struct RSMTextureAnimation: Sendable {
    public let textureIndex: Int32                  // index into node.textures
    public let tracks: [RSMTextureAnimationTrack]
}

public let textureAnimations: [RSMTextureAnimation]  // empty when none
```

Populate from `rsm.nodes[i].textureKeyframeGroups` during the Phase 1 construction (so the data is already present once Phase 5 starts — Phase 1 may stash the array and Phase 5 makes it functional).

A node's mesh whose `textureName` matches `node.textures[textureIndex]` is the one targeted by a given `RSMTextureAnimation`. During mesh emission (Phase 1's compile step), record each `RSMModelNodeMesh`'s `textureIndex` alongside `textureName`, so the renderer can look up "is this mesh animated?" without string compare.

### 5.3 Animator extension

Add to `RSMModelAnimator`:

```swift
/// Returns the 3x3 affine UV transform applied to a node's mesh at the given frame.
/// Defaults to the identity when the node has no animation for this textureIndex.
public func textureMatrix(
    for node: RSMModelNode,
    textureIndex: Int32,
    atFrame frame: Float
) -> simd_float3x3
```

Implementation:

1. Find the `RSMTextureAnimation` matching `textureIndex` on the node (linear scan over a typically-empty array).
2. For each track type, interpolate the keyframes at `frame` (linear scan, same as the geometry tracks).
3. Compose the matrix per the formula in 5.1. Return identity when no animation matches.

Static (no-keyframe) meshes don't need to hit this method; the renderer short-circuits the same way it does for bone matrices.

### 5.4 Shader changes

In `ModelShaderTypes.h`, add a new push-constant struct:

```c
typedef struct {
    matrix_float3x3 uvMatrix;
} ModelTextureUniforms;
```

Bind at `buffer(4)` on the vertex shader. Update `modelVertexShader`:

```metal
float3 uv = float3(in.textureCoordinate, 1.0);
uv = texUniforms.uvMatrix * uv;
out.textureCoordinate = uv.xy;
```

(Applied in the vertex shader — affine transforms on UVs survive perspective-correct interpolation cleanly, and per-vertex is cheaper than per-fragment.)

Fragment shader unchanged.

### 5.5 Resource changes

Extend `RSMModelRenderResource`:

- Each per-mesh entry already carries node info from Phase 2; add `textureIndex: Int32` to it (from `RSMModelNodeMesh`).
- Add `let hasAnyTextureKeyframes: Bool` derived once from the asset (any node has any non-empty `textureAnimations`).
- Cache identity uniforms once for the static fast path:
  ```
  identityTextureUniforms = ModelTextureUniforms(uvMatrix: identity)
  ```

### 5.6 Renderer changes

In `RSMModelRenderer.render(...)`:

- For each resource:
  - The geometry-animation branch from Phase 4 already decides whether to allocate an animator and evaluate poses. Reuse the same animator instance here.
  - Per draw call: if `resource.hasAnyTextureKeyframes` and the mesh's node has a matching `RSMTextureAnimation`, compute `var texUniforms = ModelTextureUniforms(uvMatrix: animator.textureMatrix(for: node, textureIndex: mesh.textureIndex, atFrame: frame))`; otherwise use `resource.identityTextureUniforms`.
  - `setVertexBytes(&texUniforms, length: stride, index: 4)` before `drawPrimitives`.

A model with geometry animation but no texture animation pays one extra `setVertexBytes` of an identity matrix per draw — negligible. A purely-static model is also paying that, also negligible.

### 5.7 Acceptance criteria for Phase 5

- A known texture-animated map renders moving UVs on Metal. Concrete candidates to verify against (must spot-check during implementation):
  - `prontera` clock tower (rumored flowing texture on the gears).
  - `thor_v01` / `thor_v03` (lava floors and walls).
  - `iz_dun03` / `iz_dun04` (underwater scrolling textures).
- Models without texture animation render pixel-equivalent to Phase 4.
- visionOS renders the same as Phase 4 (texture animation explicitly out-of-scope there).
- `swift build` clean across packages.
- Visual calibration step (one-time): pick one canonical texture-animated mesh, render at known `frame` values (0, animationLength/4, animationLength/2, …) and confirm the UV transformation direction matches the official client. If the composition order in 5.1 is wrong, fix once and re-verify.

---

## Sizing and Sequencing

| Phase | Scope | Risk | Approx files touched |
|-------|-------|------|----------------------|
| 1 | Asset internal refactor; tree added alongside flat `meshes` | Low | 1 |
| 2 | Metal switches to tree + bone-matrix push constant; shader updated; single pipeline | Medium | 4 (asset unchanged, resource + renderer + shader + header) |
| 3 | RealityKit switches to entity tree; legacy `meshes` removed | Medium-high (visual diff risk) | 2 (asset + entity init) |
| 4 | Animator + Metal wiring | Small-medium | 3 (new animator + resource flag + renderer branch) |
| 5 | Texture animation on Metal | Small-medium | 5 (asset node + animator + shader + header + renderer) |

Each phase is independently shippable and reviewable. Phases 2 and 3 are not ordered relative to each other — they can run in either order, or in parallel branches. The order above is chosen because Phase 3 is the highest visual-diff risk and benefits from landing after Metal has demonstrated the tree-walk works. Phase 5 depends on Phase 4 (it reuses the animator and the per-frame evaluation hook in the renderer), but is otherwise independent.

## Out-of-scope Follow-ups

- Geometry animation on RealityKit (visionOS). Would attach a per-node `Component` and a `System` that writes `entity.transform.matrix = animator.localTransform(...) × T(offset) × mat3` each tick. Cheap to add once the Phase 4 animator exists; decide based on whether visionOS users actually notice frozen treasure chests / doors.
- Texture animation on RealityKit. Would need `CustomMaterial` (or a dynamic-mesh hack rewriting tvertices per frame). Higher cost than geometry animation; defer until there's a separate reason to introduce `CustomMaterial` on visionOS.
- Per-node frustum culling for animated meshes.
- Compute-shader bone-matrix evaluation if profiling shows the CPU animator dominates a frame.

These can be picked up independently after Phase 5 lands.
