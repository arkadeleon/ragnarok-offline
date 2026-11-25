//
//  EffectPrimitiveBatchCollector.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/24.
//

import Foundation
import Metal
import RagnarokRendering
import RagnarokShaders
import simd

@MainActor
public protocol EffectPrimitiveRenderable: EffectInstance {
    func collectPrimitiveBatches(
        into collector: inout EffectPrimitiveBatchCollector,
        fog: Fog,
        modelMatrix: simd_float4x4,
        world: any EffectWorldContext
    )
}

public struct EffectPrimitiveBatchCollector {
    public let fog: Fog
    public let modelMatrix: simd_float4x4
    public private(set) var batches: [EffectPrimitiveBatchRenderer.RenderPayload] = []

    public init(fog: Fog = Fog(), modelMatrix: simd_float4x4 = matrix_identity_float4x4) {
        self.fog = fog
        self.modelMatrix = modelMatrix
    }

    @inlinable
    public static func unpackARGB(_ argb: UInt32) -> SIMD4<Float> {
        let a = Float((argb >> 24) & 0xFF) / 255.0
        let r = Float((argb >> 16) & 0xFF) / 255.0
        let g = Float((argb >> 8) & 0xFF) / 255.0
        let b = Float(argb & 0xFF) / 255.0
        return SIMD4<Float>(r, g, b, a)
    }

    public mutating func appendWorldTriangle(
        v0: SIMD3<Float>,
        v1: SIMD3<Float>,
        v2: SIMD3<Float>,
        uv0: SIMD2<Float>,
        uv1: SIMD2<Float>,
        uv2: SIMD2<Float>,
        color0: SIMD4<Float>,
        color1: SIMD4<Float>,
        color2: SIMD4<Float>,
        texture: (any MTLTexture)?,
        renderState: EffectPrimitiveRenderState,
        worldCenter: SIMD3<Float>
    ) {
        let vertices = [
            EffectPrimitiveVertex(position: v0, billboardOffset: .zero, textureCoordinate: uv0, color: color0),
            EffectPrimitiveVertex(position: v1, billboardOffset: .zero, textureCoordinate: uv1, color: color1),
            EffectPrimitiveVertex(position: v2, billboardOffset: .zero, textureCoordinate: uv2, color: color2),
        ]
        appendVertices(
            vertices,
            mode: .world3D,
            texture: texture,
            renderState: renderState,
            worldCenter: worldCenter
        )
    }

    public mutating func appendEffectTriangle(
        p0: SIMD3<Float>,
        p1: SIMD3<Float>,
        p2: SIMD3<Float>,
        uv0: SIMD2<Float>,
        uv1: SIMD2<Float>,
        uv2: SIMD2<Float>,
        color0: SIMD4<Float>,
        color1: SIMD4<Float>,
        color2: SIMD4<Float>,
        texture: (any MTLTexture)?,
        renderState: EffectPrimitiveRenderState,
        effectCenter: SIMD3<Float>
    ) {
        appendWorldTriangle(
            v0: EffectSpace.toWorldPosition(p0),
            v1: EffectSpace.toWorldPosition(p1),
            v2: EffectSpace.toWorldPosition(p2),
            uv0: uv0,
            uv1: uv1,
            uv2: uv2,
            color0: color0,
            color1: color1,
            color2: color2,
            texture: texture,
            renderState: renderState,
            worldCenter: EffectSpace.toWorldPosition(effectCenter)
        )
    }

    /// Appends a quad `(p0, p1, p2, p3)` in effect space as two triangles `(p0, p1, p2)` and `(p0, p2, p3)`.
    public mutating func appendEffectQuad(
        p0: SIMD3<Float>,
        p1: SIMD3<Float>,
        p2: SIMD3<Float>,
        p3: SIMD3<Float>,
        uv0: SIMD2<Float> = SIMD2<Float>(0, 0),
        uv1: SIMD2<Float> = SIMD2<Float>(1, 0),
        uv2: SIMD2<Float> = SIMD2<Float>(1, 1),
        uv3: SIMD2<Float> = SIMD2<Float>(0, 1),
        color0: SIMD4<Float>,
        color1: SIMD4<Float>,
        color2: SIMD4<Float>,
        color3: SIMD4<Float>,
        texture: (any MTLTexture)?,
        renderState: EffectPrimitiveRenderState,
        effectCenter: SIMD3<Float>
    ) {
        let w0 = EffectSpace.toWorldPosition(p0)
        let w1 = EffectSpace.toWorldPosition(p1)
        let w2 = EffectSpace.toWorldPosition(p2)
        let w3 = EffectSpace.toWorldPosition(p3)
        let worldCenter = EffectSpace.toWorldPosition(effectCenter)

        let vertices = [
            EffectPrimitiveVertex(position: w0, billboardOffset: .zero, textureCoordinate: uv0, color: color0),
            EffectPrimitiveVertex(position: w1, billboardOffset: .zero, textureCoordinate: uv1, color: color1),
            EffectPrimitiveVertex(position: w2, billboardOffset: .zero, textureCoordinate: uv2, color: color2),
            EffectPrimitiveVertex(position: w0, billboardOffset: .zero, textureCoordinate: uv0, color: color0),
            EffectPrimitiveVertex(position: w2, billboardOffset: .zero, textureCoordinate: uv2, color: color2),
            EffectPrimitiveVertex(position: w3, billboardOffset: .zero, textureCoordinate: uv3, color: color3),
        ]
        appendVertices(
            vertices,
            mode: .world3D,
            texture: texture,
            renderState: renderState,
            worldCenter: worldCenter
        )
    }

    public mutating func appendEffectBillboardQuad(
        anchorEffectPosition: SIMD3<Float>,
        sizeEffect: SIMD2<Float>,
        rotationRadians: Float = 0,
        uvMin: SIMD2<Float> = SIMD2<Float>(0, 0),
        uvMax: SIMD2<Float> = SIMD2<Float>(1, 1),
        color: SIMD4<Float>,
        texture: (any MTLTexture)?,
        renderState: EffectPrimitiveRenderState
    ) {
        let worldAnchor = EffectSpace.toWorldPosition(anchorEffectPosition)
        let halfWidth = EffectSpace.toWorldDistance(sizeEffect.x) * 0.5
        let halfHeight = EffectSpace.toWorldDistance(sizeEffect.y) * 0.5

        let c = cosf(rotationRadians)
        let s = sinf(rotationRadians)
        func rotate(_ x: Float, _ y: Float) -> SIMD2<Float> {
            SIMD2<Float>(x * c - y * s, x * s + y * c)
        }

        let offsetTL = rotate(-halfWidth, halfHeight)
        let offsetTR = rotate(halfWidth, halfHeight)
        let offsetBR = rotate(halfWidth, -halfHeight)
        let offsetBL = rotate(-halfWidth, -halfHeight)

        let uvTL = SIMD2<Float>(uvMin.x, uvMin.y)
        let uvTR = SIMD2<Float>(uvMax.x, uvMin.y)
        let uvBR = SIMD2<Float>(uvMax.x, uvMax.y)
        let uvBL = SIMD2<Float>(uvMin.x, uvMax.y)

        let vertices = [
            EffectPrimitiveVertex(position: worldAnchor, billboardOffset: offsetTL, textureCoordinate: uvTL, color: color),
            EffectPrimitiveVertex(position: worldAnchor, billboardOffset: offsetTR, textureCoordinate: uvTR, color: color),
            EffectPrimitiveVertex(position: worldAnchor, billboardOffset: offsetBR, textureCoordinate: uvBR, color: color),
            EffectPrimitiveVertex(position: worldAnchor, billboardOffset: offsetTL, textureCoordinate: uvTL, color: color),
            EffectPrimitiveVertex(position: worldAnchor, billboardOffset: offsetBR, textureCoordinate: uvBR, color: color),
            EffectPrimitiveVertex(position: worldAnchor, billboardOffset: offsetBL, textureCoordinate: uvBL, color: color),
        ]
        appendVertices(
            vertices,
            mode: .billboard3D,
            texture: texture,
            renderState: renderState,
            worldCenter: worldAnchor
        )
    }

    public mutating func appendBillboardQuad(
        anchorEffectPosition: SIMD3<Float>,
        offset0: SIMD2<Float>,
        offset1: SIMD2<Float>,
        offset2: SIMD2<Float>,
        offset3: SIMD2<Float>,
        uv0: SIMD2<Float> = SIMD2<Float>(0, 0),
        uv1: SIMD2<Float> = SIMD2<Float>(1, 0),
        uv2: SIMD2<Float> = SIMD2<Float>(1, 1),
        uv3: SIMD2<Float> = SIMD2<Float>(0, 1),
        color: SIMD4<Float>,
        texture: (any MTLTexture)?,
        renderState: EffectPrimitiveRenderState
    ) {
        let worldAnchor = EffectSpace.toWorldPosition(anchorEffectPosition)
        let vertices = [
            EffectPrimitiveVertex(position: worldAnchor, billboardOffset: offset0, textureCoordinate: uv0, color: color),
            EffectPrimitiveVertex(position: worldAnchor, billboardOffset: offset1, textureCoordinate: uv1, color: color),
            EffectPrimitiveVertex(position: worldAnchor, billboardOffset: offset2, textureCoordinate: uv2, color: color),
            EffectPrimitiveVertex(position: worldAnchor, billboardOffset: offset0, textureCoordinate: uv0, color: color),
            EffectPrimitiveVertex(position: worldAnchor, billboardOffset: offset2, textureCoordinate: uv2, color: color),
            EffectPrimitiveVertex(position: worldAnchor, billboardOffset: offset3, textureCoordinate: uv3, color: color),
        ]
        appendVertices(
            vertices,
            mode: .billboard3D,
            texture: texture,
            renderState: renderState,
            worldCenter: worldAnchor
        )
    }

    public mutating func appendScreen2DTriangle(
        anchorEffectPosition: SIMD3<Float>,
        offset0: SIMD2<Float>,
        offset1: SIMD2<Float>,
        offset2: SIMD2<Float>,
        uv0: SIMD2<Float>,
        uv1: SIMD2<Float>,
        uv2: SIMD2<Float>,
        color0: SIMD4<Float>,
        color1: SIMD4<Float>,
        color2: SIMD4<Float>,
        texture: (any MTLTexture)?,
        renderState: EffectPrimitiveRenderState,
        isAbsoluteScreen: Bool = false
    ) {
        let basePosition = isAbsoluteScreen
            ? SIMD3<Float>(anchorEffectPosition.x, anchorEffectPosition.y, 0)
            : EffectSpace.toWorldPosition(anchorEffectPosition)
        let worldCenter = isAbsoluteScreen ? .zero : basePosition
        let mode: EffectPrimitiveRenderMode = isAbsoluteScreen ? .screen2DAbsolute : .screen2D

        let vertices = [
            EffectPrimitiveVertex(position: basePosition, billboardOffset: offset0, textureCoordinate: uv0, color: color0),
            EffectPrimitiveVertex(position: basePosition, billboardOffset: offset1, textureCoordinate: uv1, color: color1),
            EffectPrimitiveVertex(position: basePosition, billboardOffset: offset2, textureCoordinate: uv2, color: color2),
        ]
        appendVertices(
            vertices,
            mode: mode,
            texture: texture,
            renderState: renderState,
            worldCenter: worldCenter
        )
    }

    public mutating func appendScreen2DQuad(
        anchorEffectPosition: SIMD3<Float>,
        offset0: SIMD2<Float>,
        offset1: SIMD2<Float>,
        offset2: SIMD2<Float>,
        offset3: SIMD2<Float>,
        uv0: SIMD2<Float> = SIMD2<Float>(0, 0),
        uv1: SIMD2<Float> = SIMD2<Float>(1, 0),
        uv2: SIMD2<Float> = SIMD2<Float>(1, 1),
        uv3: SIMD2<Float> = SIMD2<Float>(0, 1),
        color0: SIMD4<Float>,
        color1: SIMD4<Float>,
        color2: SIMD4<Float>,
        color3: SIMD4<Float>,
        texture: (any MTLTexture)?,
        renderState: EffectPrimitiveRenderState,
        isAbsoluteScreen: Bool = false
    ) {
        let basePosition = isAbsoluteScreen
            ? SIMD3<Float>(anchorEffectPosition.x, anchorEffectPosition.y, 0)
            : EffectSpace.toWorldPosition(anchorEffectPosition)
        let worldCenter = isAbsoluteScreen ? .zero : basePosition
        let mode: EffectPrimitiveRenderMode = isAbsoluteScreen ? .screen2DAbsolute : .screen2D

        let vertices = [
            EffectPrimitiveVertex(position: basePosition, billboardOffset: offset0, textureCoordinate: uv0, color: color0),
            EffectPrimitiveVertex(position: basePosition, billboardOffset: offset1, textureCoordinate: uv1, color: color1),
            EffectPrimitiveVertex(position: basePosition, billboardOffset: offset2, textureCoordinate: uv2, color: color2),
            EffectPrimitiveVertex(position: basePosition, billboardOffset: offset0, textureCoordinate: uv0, color: color0),
            EffectPrimitiveVertex(position: basePosition, billboardOffset: offset2, textureCoordinate: uv2, color: color2),
            EffectPrimitiveVertex(position: basePosition, billboardOffset: offset3, textureCoordinate: uv3, color: color3),
        ]
        appendVertices(
            vertices,
            mode: mode,
            texture: texture,
            renderState: renderState,
            worldCenter: worldCenter
        )
    }

    private mutating func appendVertices(
        _ vertices: [EffectPrimitiveVertex],
        mode: EffectPrimitiveRenderMode,
        texture: (any MTLTexture)?,
        renderState: EffectPrimitiveRenderState,
        worldCenter: SIMD3<Float>
    ) {
        if let lastIndex = batches.indices.last,
           batches[lastIndex].mode == mode,
           batches[lastIndex].renderState == renderState,
           Self.texturesMatch(batches[lastIndex].texture, texture) {
            batches[lastIndex].vertices.append(contentsOf: vertices)
        } else {
            batches.append(
                EffectPrimitiveBatchRenderer.RenderPayload(
                    mode: mode,
                    texture: texture,
                    renderState: renderState,
                    worldCenter: worldCenter,
                    fog: fog,
                    modelMatrix: modelMatrix,
                    vertices: vertices
                )
            )
        }
    }

    private static func texturesMatch(_ lhs: (any MTLTexture)?, _ rhs: (any MTLTexture)?) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            true
        case (.some(let left), .some(let right)):
            ObjectIdentifier(left) == ObjectIdentifier(right)
        default:
            false
        }
    }
}
