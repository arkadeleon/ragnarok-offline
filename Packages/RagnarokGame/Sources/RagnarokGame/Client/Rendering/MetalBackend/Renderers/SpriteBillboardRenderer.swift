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
import RagnarokResources
import RagnarokShaders
import RagnarokSprite
import simd

@MainActor
final class SpriteBillboardRenderer {
    private struct SpriteEntry {
        let objectID: UInt32
        var texture: (any MTLTexture)?
        var frameWidth: Float
        var frameHeight: Float
        var worldPosition: SIMD3<Float>
        var isVisible: Bool
    }

    /// Screen-space bounding boxes (top-left origin) updated each render call.
    private(set) var hitBoxes: [UInt32 : CGRect] = [:]

    private let device: any MTLDevice
    private var renderPipelineState: (any MTLRenderPipelineState)?
    private var depthStencilState: (any MTLDepthStencilState)?

    private var entries: [UInt32 : SpriteEntry] = [:]
    private var loadTasks: [UInt32 : Task<Void, Never>] = [:]

    init(device: any MTLDevice) throws {
        self.device = device

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

    func syncObjects(
        player: MapObjectState,
        objects: [UInt32 : MapObjectState],
        items: [UInt32 : MapItemState],
        scene: MapScene,
        resourceManager: ResourceManager
    ) {
        var objectIDs = Set<UInt32>()
        objectIDs.insert(player.id)
        for objectID in objects.keys {
            objectIDs.insert(objectID)
        }

        var itemIDs = Set<UInt32>()
        for id in items.keys {
            itemIDs.insert(id)
        }

        let currentIDs = objectIDs.union(itemIDs)

        for id in Set(entries.keys).subtracting(currentIDs) {
            entries.removeValue(forKey: id)
            loadTasks[id]?.cancel()
            loadTasks.removeValue(forKey: id)
        }

        entries[player.id]?.worldPosition = scene.position(for: player.gridPosition)
        entries[player.id]?.isVisible = player.isVisible
        for (id, obj) in objects {
            entries[id]?.worldPosition = scene.position(for: obj.gridPosition)
            entries[id]?.isVisible = obj.isVisible
        }
        for (id, item) in items {
            entries[id]?.worldPosition = scene.position(for: item.gridPosition)
        }

        let allObjects: [(UInt32, MapObjectState)] = [(player.id, player)] + objects.map { ($0.key, $0.value) }
        for (id, objState) in allObjects {
            guard entries[id] == nil, loadTasks[id] == nil else {
                continue
            }

            entries[id] = SpriteEntry(
                objectID: id,
                texture: nil,
                frameWidth: 64,
                frameHeight: 64,
                worldPosition: scene.position(for: objState.gridPosition),
                isVisible: objState.isVisible
            )

            let mapObject = objState.object
            let worldPosition = scene.position(for: objState.gridPosition)
            loadTasks[id] = Task { [weak self] in
                guard let self else {
                    return
                }

                let configuration = ComposedSprite.Configuration(mapObject: mapObject)
                guard let composedSprite = try? await ComposedSprite(
                    configuration: configuration,
                    resourceManager: resourceManager
                ) else {
                    return
                }

                guard !Task.isCancelled else {
                    return
                }

                let animation = await SpriteRenderer().render(
                    composedSprite: composedSprite,
                    actionType: .idle,
                    direction: .south,
                    rendersShadow: false
                )

                guard !Task.isCancelled else {
                    return
                }

                let texture = MapMetalTextureFactory.makeTexture(
                    from: animation.firstFrame,
                    device: self.device,
                    label: "sprite-obj-\(id)"
                )

                self.entries[id]?.texture = texture
                self.entries[id]?.frameWidth = Float(animation.frameWidth)
                self.entries[id]?.frameHeight = Float(animation.frameHeight)
                self.entries[id]?.worldPosition = worldPosition
            }
        }

        for (id, itemState) in items {
            guard entries[id] == nil, loadTasks[id] == nil else {
                continue
            }

            entries[id] = SpriteEntry(
                objectID: id,
                texture: nil,
                frameWidth: 32,
                frameHeight: 32,
                worldPosition: scene.position(for: itemState.gridPosition),
                isVisible: true
            )

            let mapItem = itemState.item
            loadTasks[id] = Task { [weak self] in
                guard let self else {
                    return
                }

                let scriptContext = await resourceManager.scriptContext()
                guard let path = ResourcePath.generateItemSpritePath(
                    itemID: Int(mapItem.itemID),
                    scriptContext: scriptContext
                ),
                let sprite = try? await resourceManager.sprite(at: path) else {
                    return
                }

                guard !Task.isCancelled else {
                    return
                }

                let animation = await SpriteRenderer().render(sprite: sprite, actionIndex: 0)

                guard !Task.isCancelled else {
                    return
                }
                let texture = MapMetalTextureFactory.makeTexture(
                    from: animation.firstFrame,
                    device: self.device,
                    label: "sprite-item-\(id)"
                )

                self.entries[id]?.texture = texture
                self.entries[id]?.frameWidth = Float(animation.frameWidth)
                self.entries[id]?.frameHeight = Float(animation.frameHeight)
            }
        }
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

        for (id, entry) in entries {
            guard entry.isVisible, let texture = entry.texture else {
                continue
            }

            let halfW = entry.frameWidth / 2
            let h = entry.frameHeight

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
                spriteWorldPosition: SIMD4<Float>(entry.worldPosition, 0)
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

            if let hitBox = computeHitBox(for: entry, matrices: matrices, viewport: viewport) {
                newHitBoxes[id] = hitBox
            }
        }

        hitBoxes = newHitBoxes
    }

    func cancelAllTasks() {
        for task in loadTasks.values {
            task.cancel()
        }
        loadTasks.removeAll()
        entries.removeAll()
        hitBoxes.removeAll()
    }

    private func computeHitBox(
        for entry: SpriteEntry,
        matrices: MapRuntimeRenderer.RenderMatrices,
        viewport: CGRect
    ) -> CGRect? {
        let pv = matrices.projectionMatrix * matrices.viewMatrix

        let right = SIMD3<Float>(
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

            // NDC → screen coords (top-left origin).
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
