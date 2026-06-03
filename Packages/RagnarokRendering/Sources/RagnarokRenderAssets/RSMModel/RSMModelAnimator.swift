//
//  RSMModelAnimator.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/6/3.
//

import CoreFoundation
import RagnarokCore
import RagnarokFileFormats
import RagnarokShaders
import simd

/// Evaluates per-node poses for an RSM model.
///
/// Static models trivially fall through to default values; animated models interpolate
/// keyframes. There is no "is animated" code path — a node with empty keyframe arrays
/// produces the same matrix as the cached rest pose.
public struct RSMModelAnimator {
    public let asset: RSMModelRenderAsset

    public init(asset: RSMModelRenderAsset) {
        self.asset = asset
    }

    /// `(time * fps) mod animationLength`, wrapped to a non-negative value.
    public static func frame(at time: CFTimeInterval, asset: RSMModelRenderAsset) -> Float {
        let fps = max(asset.frameRatePerSecond, 1)
        let length = max(Float(asset.animationLength), 1)
        var f = Float(time) * fps
        f = f.truncatingRemainder(dividingBy: length)
        if f < 0 { f += length }
        return f
    }

    /// `T(animatedPos) × R(animatedRot) × S(animatedScale)`, falling back to node
    /// defaults when a track is empty. Equivalent to the rest-pose "local for children"
    /// matrix when every keyframe array is empty.
    public func localTransform(for node: RSMModelNode, atFrame frame: Float) -> simd_float4x4 {
        let position = interpolatedPosition(for: node, atFrame: frame)
        let rotation = interpolatedRotation(for: node, atFrame: frame)
        let scale = interpolatedScale(for: node, atFrame: frame)

        var m = matrix_identity_float4x4
        m = matrix_translate(m, position)
        m *= simd_float4x4(rotation)
        m = matrix_scale(m, scale)
        return m
    }

    /// `T(centerCorrection) × worldTransformForChildren(parent) × (localTransform(node) × T(offset) × mat3)`.
    ///
    /// Walks ancestors to recompute the parent's world-for-children matrix. For
    /// per-frame whole-tree evaluation prefer `evaluateBoneMatrices(atFrame:)`, which
    /// caches each parent's result in a single forward sweep.
    public func boneMatrix(for node: RSMModelNode, atFrame frame: Float) -> simd_float4x4 {
        let centerCorrection = matrix_translate(matrix_identity_float4x4, asset.centerCorrection)
        let parentWorldChildren = worldForChildren(of: node.parent, atFrame: frame)
        let local = localTransform(for: node, atFrame: frame)
        let transform = local
            * matrix_translate(matrix_identity_float4x4, node.offset)
            * simd_float4x4(node.transformMatrix)
        return centerCorrection * parentWorldChildren * transform
    }

    /// Evaluates `ModelBoneUniforms` for every node in `asset.nodes`, indexed by node index.
    /// Walks the DFS-ordered nodes once, reusing each parent's cached world-for-children.
    public func evaluateBoneMatrices(atFrame frame: Float) -> [ModelBoneUniforms] {
        let nodeCount = asset.nodes.count
        var worldForChildren = [simd_float4x4](repeating: matrix_identity_float4x4, count: nodeCount)
        var bones = [ModelBoneUniforms](
            repeating: ModelBoneUniforms(
                boneMatrix: matrix_identity_float4x4,
                boneNormalMatrix: matrix_identity_float3x3
            ),
            count: nodeCount
        )

        let centerCorrection = matrix_translate(matrix_identity_float4x4, asset.centerCorrection)

        for node in asset.nodes {
            let parentWorldChildren: simd_float4x4
            if let parent = node.parent {
                parentWorldChildren = worldForChildren[parent.index]
            } else {
                parentWorldChildren = matrix_identity_float4x4
            }

            let local = localTransform(for: node, atFrame: frame)
            let transform = local
                * matrix_translate(matrix_identity_float4x4, node.offset)
                * simd_float4x4(node.transformMatrix)

            worldForChildren[node.index] = parentWorldChildren * local

            let boneMatrix = centerCorrection * parentWorldChildren * transform
            bones[node.index] = ModelBoneUniforms(
                boneMatrix: boneMatrix,
                boneNormalMatrix: simd_float3x3(boneMatrix).inverse.transpose
            )
        }

        return bones
    }

    // MARK: - Track interpolation

    private func interpolatedPosition(for node: RSMModelNode, atFrame frame: Float) -> SIMD3<Float> {
        let kfs = node.positionKeyframes
        guard !kfs.isEmpty else { return node.position }
        if kfs.count == 1 { return kfs[0].position }
        if frame <= Float(kfs.first!.frame) { return kfs.first!.position }
        if frame >= Float(kfs.last!.frame) { return kfs.last!.position }
        for i in 0..<(kfs.count - 1) {
            let a = kfs[i]
            let b = kfs[i + 1]
            if frame >= Float(a.frame) && frame <= Float(b.frame) {
                let span = Float(b.frame) - Float(a.frame)
                let t = span > 0 ? (frame - Float(a.frame)) / span : 0
                return a.position + (b.position - a.position) * t
            }
        }
        return kfs.last!.position
    }

    private func interpolatedRotation(for node: RSMModelNode, atFrame frame: Float) -> simd_quatf {
        let kfs = node.rotationKeyframes
        if kfs.isEmpty {
            return simd_quatf(angle: node.rotationAngle, axis: node.rotationAxis)
        }
        if kfs.count == 1 { return kfs[0].quaternion }
        if frame <= Float(kfs.first!.frame) { return kfs.first!.quaternion }
        if frame >= Float(kfs.last!.frame) { return kfs.last!.quaternion }
        for i in 0..<(kfs.count - 1) {
            let a = kfs[i]
            let b = kfs[i + 1]
            if frame >= Float(a.frame) && frame <= Float(b.frame) {
                let span = Float(b.frame) - Float(a.frame)
                let t = span > 0 ? (frame - Float(a.frame)) / span : 0
                return simd_slerp(a.quaternion, b.quaternion, t)
            }
        }
        return kfs.last!.quaternion
    }

    private func interpolatedScale(for node: RSMModelNode, atFrame frame: Float) -> SIMD3<Float> {
        let kfs = node.scaleKeyframes
        guard !kfs.isEmpty else { return node.scale }
        if kfs.count == 1 { return kfs[0].scale }
        if frame <= Float(kfs.first!.frame) { return kfs.first!.scale }
        if frame >= Float(kfs.last!.frame) { return kfs.last!.scale }
        for i in 0..<(kfs.count - 1) {
            let a = kfs[i]
            let b = kfs[i + 1]
            if frame >= Float(a.frame) && frame <= Float(b.frame) {
                let span = Float(b.frame) - Float(a.frame)
                let t = span > 0 ? (frame - Float(a.frame)) / span : 0
                return a.scale + (b.scale - a.scale) * t
            }
        }
        return kfs.last!.scale
    }

    // MARK: - Ancestor walk

    private func worldForChildren(of node: RSMModelNode?, atFrame frame: Float) -> simd_float4x4 {
        guard let node else { return matrix_identity_float4x4 }
        return worldForChildren(of: node.parent, atFrame: frame) * localTransform(for: node, atFrame: frame)
    }
}
