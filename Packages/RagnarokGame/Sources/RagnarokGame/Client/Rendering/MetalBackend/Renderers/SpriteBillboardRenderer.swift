//
//  SpriteBillboardRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/23.
//

#if os(iOS) || os(macOS)

import CoreGraphics
import Metal
import RagnarokRenderers
import RagnarokShaders
import simd

@MainActor
final class SpriteBillboardRenderer {
    private var renderPipelineState: (any MTLRenderPipelineState)?
    private var depthStencilState: (any MTLDepthStencilState)?

    private var drawables: [UInt32 : SpriteBillboardDrawable] = [:]

    /// Screen-space bounding boxes (top-left origin) updated each render call.
    private(set) var hitBoxes: [UInt32 : CGRect] = [:]

    init(device: any MTLDevice) throws {
        let library = ragnarokShadersLibrary(device: device)!

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "spriteBillboardVertexShader")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "spriteBillboardFragmentShader")
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        self.renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .lessEqual
        depthStencilDescriptor.isDepthWriteEnabled = false
        self.depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }

    func update(drawables: [UInt32 : SpriteBillboardDrawable]) {
        self.drawables = drawables
    }

    func reset() {
        drawables.removeAll()
        hitBoxes.removeAll()
    }

    func render(
        atTime time: CFTimeInterval,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        matrices: MapRuntimeRenderer.RenderMatrices,
        viewport: CGRect
    ) {
        guard let renderPipelineState, let depthStencilState else {
            return
        }

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        var newHitBoxes: [UInt32: CGRect] = [:]

        for (id, drawable) in drawables {
            guard drawable.isVisible, let texture = drawable.texture else {
                continue
            }

            let halfW = drawable.frameWidth / 2
            let h = drawable.frameHeight

            var vertices: [SpriteVertex] = [
                SpriteVertex(position: [-halfW, 0], textureCoordinate: [0, 1]),
                SpriteVertex(position: [ halfW, 0], textureCoordinate: [1, 1]),
                SpriteVertex(position: [-halfW, h], textureCoordinate: [0, 0]),
                SpriteVertex(position: [ halfW, 0], textureCoordinate: [1, 1]),
                SpriteVertex(position: [ halfW, h], textureCoordinate: [1, 0]),
                SpriteVertex(position: [-halfW, h], textureCoordinate: [0, 0]),
            ]

            let device = renderCommandEncoder.device

            guard let vertexBuffer = device.makeBuffer(
                bytes: &vertices,
                length: vertices.count * MemoryLayout<SpriteVertex>.stride,
                options: []
            ) else {
                continue
            }

            var uniforms = SpriteVertexUniforms(
                viewMatrix: matrices.viewMatrix,
                projectionMatrix: matrices.projectionMatrix,
                spriteWorldPosition: SIMD4<Float>(drawable.worldPosition, 0)
            )
            guard let uniformsBuffer = device.makeBuffer(
                bytes: &uniforms,
                length: MemoryLayout<SpriteVertexUniforms>.stride,
                options: []
            ) else {
                continue
            }

            renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            renderCommandEncoder.setVertexBuffer(uniformsBuffer, offset: 0, index: 1)
            renderCommandEncoder.setFragmentTexture(texture, index: 0)
            renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)

            if let hitBox = computeHitBox(for: drawable, matrices: matrices, viewport: viewport) {
                newHitBoxes[id] = hitBox
            }
        }

        hitBoxes = newHitBoxes
    }

    private func computeHitBox(
        for entry: SpriteBillboardDrawable,
        matrices: MapRuntimeRenderer.RenderMatrices,
        viewport: CGRect
    ) -> CGRect? {
        let pv = matrices.projectionMatrix * matrices.viewMatrix

        let right = -SIMD3<Float>(
            matrices.viewMatrix[0][0],
            matrices.viewMatrix[1][0],
            matrices.viewMatrix[2][0]
        )
        let up = SIMD3<Float>(
            matrices.viewMatrix[0][1],
            matrices.viewMatrix[1][1],
            matrices.viewMatrix[2][1]
        )

        let halfW = entry.frameWidth / 2
        let h = entry.frameHeight
        let scale: Float = 1.0 / 32.0

        let corners: [SIMD3<Float>] = [
            entry.worldPosition + (-right * halfW + up * 0) * scale,
            entry.worldPosition + ( right * halfW + up * 0) * scale,
            entry.worldPosition + (-right * halfW + up * h) * scale,
            entry.worldPosition + ( right * halfW + up * h) * scale,
        ]

        var minX = CGFloat.infinity
        var minY = CGFloat.infinity
        var maxX = -CGFloat.infinity
        var maxY = -CGFloat.infinity

        for corner in corners {
            let clip = pv * SIMD4<Float>(corner, 1)
            guard clip.w > 0 else {
                return nil
            }

            let ndcX = clip.x / clip.w
            let ndcY = clip.y / clip.w

            let sx = viewport.minX + CGFloat((ndcX + 1) * 0.5) * viewport.width
            let sy = viewport.minY + CGFloat((1 - ndcY) * 0.5) * viewport.height

            minX = min(minX, sx)
            minY = min(minY, sy)
            maxX = max(maxX, sx)
            maxY = max(maxY, sy)
        }

        guard minX < maxX, minY < maxY else {
            return nil
        }

        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}

#endif
