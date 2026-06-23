//
//  RSMModelAnimator.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/6/3.
//

import Foundation
import RagnarokCore
import RagnarokFileFormats
import RagnarokShaders
import simd

/// Evaluates per-node transforms for an RSM model by interpolating animation keyframes.
public struct RSMModelAnimator {
    public let asset: RSMModelRenderAsset

    public init(asset: RSMModelRenderAsset) {
        self.asset = asset
    }

    /// Returns the animation frame index for the given playback time.
    public func frame(atTime time: TimeInterval) -> Double {
        let animationLength = Double(asset.animationLength)
        guard animationLength > 0 else {
            return 0
        }
        let fps = Double(asset.fps)
        var frame = time * Double(fps)
        frame = frame.truncatingRemainder(dividingBy: animationLength)
        if frame < 0 {
            frame += animationLength
        }
        return frame
    }

    /// Returns the local transform for a node at the given frame, interpolating keyframes
    /// and falling back to the node's default position/rotation/scale when tracks are empty.
    public func localTransform(for node: RSMModelNode, atFrame frame: Double) -> simd_float4x4 {
        let position = interpolatedPosition(for: node, atFrame: frame)
        let rotation = interpolatedRotation(for: node, atFrame: frame)
        let scale = interpolatedScale(for: node, atFrame: frame)

        var transform = matrix_identity_float4x4
        transform = matrix_translate(transform, position)
        transform *= simd_float4x4(rotation)
        transform = matrix_scale(transform, scale)
        return transform
    }

    /// Returns the world-space bone matrix for a single node. Prefer `evaluateBoneMatrices(atFrame:)`
    /// for whole-tree evaluation, which avoids redundant ancestor walks.
    public func boneMatrix(for node: RSMModelNode, atFrame frame: Double) -> simd_float4x4 {
        let worldTransform = worldTransformForChildren(of: node.parent, atFrame: frame)
        let localTransform = localTransform(for: node, atFrame: frame)
        let transform = localTransform
            * matrix_translate(matrix_identity_float4x4, node.offset)
            * simd_float4x4(node.transformMatrix)
        return worldTransform * transform
    }

    /// Returns bone uniforms for every node, indexed by node index.
    public func evaluateBoneMatrices(atFrame frame: Double) -> [ModelBoneUniforms] {
        let nodeCount = asset.nodes.count
        var worldTransforms = [simd_float4x4](repeating: matrix_identity_float4x4, count: nodeCount)
        var bones = [ModelBoneUniforms](
            repeating: ModelBoneUniforms(
                boneMatrix: matrix_identity_float4x4,
                boneNormalMatrix: matrix_identity_float3x3
            ),
            count: nodeCount
        )

        for node in asset.nodes {
            let worldTransform: simd_float4x4
            if let parent = node.parent {
                worldTransform = worldTransforms[parent.index]
            } else {
                worldTransform = matrix_identity_float4x4
            }

            let localTransform = localTransform(for: node, atFrame: frame)
            let transform = localTransform
                * matrix_translate(matrix_identity_float4x4, node.offset)
                * simd_float4x4(node.transformMatrix)

            worldTransforms[node.index] = worldTransform * localTransform

            let boneMatrix = worldTransform * transform
            bones[node.index] = ModelBoneUniforms(
                boneMatrix: boneMatrix,
                boneNormalMatrix: simd_float3x3(boneMatrix).inverse.transpose
            )
        }

        return bones
    }

    // MARK: - Track interpolation

    private func interpolatedPosition(for node: RSMModelNode, atFrame frame: Double) -> SIMD3<Float> {
        let kfs = node.positionKeyframes
        if kfs.isEmpty {
            return node.position
        }
        if kfs.count == 1 {
            return kfs[0].position
        }
        if frame <= Double(kfs[0].frame) {
            return kfs[0].position
        }
        if frame >= Double(kfs[kfs.count - 1].frame) {
            return kfs[kfs.count - 1].position
        }
        for i in 0..<(kfs.count - 1) {
            let a = kfs[i]
            let b = kfs[i + 1]
            if frame >= Double(a.frame) && frame <= Double(b.frame) {
                let span = Double(b.frame) - Double(a.frame)
                let t = span > 0 ? (frame - Double(a.frame)) / span : 0
                return a.position + (b.position - a.position) * Float(t)
            }
        }
        return kfs[kfs.count - 1].position
    }

    private func interpolatedRotation(for node: RSMModelNode, atFrame frame: Double) -> simd_quatf {
        let kfs = node.rotationKeyframes
        if kfs.isEmpty {
            return simd_quatf(angle: node.rotationAngle, axis: node.rotationAxis)
        }
        if kfs.count == 1 {
            return kfs[0].quaternion
        }
        if frame <= Double(kfs[0].frame) {
            return kfs[0].quaternion
        }
        if frame >= Double(kfs[kfs.count - 1].frame) {
            return kfs[kfs.count - 1].quaternion
        }
        for i in 0..<(kfs.count - 1) {
            let a = kfs[i]
            let b = kfs[i + 1]
            if frame >= Double(a.frame) && frame <= Double(b.frame) {
                let span = Double(b.frame) - Double(a.frame)
                let t = span > 0 ? (frame - Double(a.frame)) / span : 0
                return simd_slerp(a.quaternion, b.quaternion, Float(t))
            }
        }
        return kfs[kfs.count - 1].quaternion
    }

    private func interpolatedScale(for node: RSMModelNode, atFrame frame: Double) -> SIMD3<Float> {
        let kfs = node.scaleKeyframes
        if kfs.isEmpty {
            return node.scale
        }
        if kfs.count == 1 {
            return kfs[0].scale
        }
        if frame <= Double(kfs[0].frame) {
            return kfs[0].scale
        }
        if frame >= Double(kfs[kfs.count - 1].frame) {
            return kfs[kfs.count - 1].scale
        }
        for i in 0..<(kfs.count - 1) {
            let a = kfs[i]
            let b = kfs[i + 1]
            if frame >= Double(a.frame) && frame <= Double(b.frame) {
                let span = Double(b.frame) - Double(a.frame)
                let t = span > 0 ? (frame - Double(a.frame)) / span : 0
                return a.scale + (b.scale - a.scale) * Float(t)
            }
        }
        return kfs[kfs.count - 1].scale
    }

    // MARK: - Ancestor walk

    private func worldTransformForChildren(of node: RSMModelNode?, atFrame frame: Double) -> simd_float4x4 {
        if let node {
            worldTransformForChildren(of: node.parent, atFrame: frame) * localTransform(for: node, atFrame: frame)
        } else {
            matrix_identity_float4x4
        }
    }
}
