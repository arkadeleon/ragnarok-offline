//
//  CylinderEffectAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/9.
//

import CoreGraphics
import RagnarokEffects
import RagnarokResources
import RagnarokShaders

public struct CylinderEffectAsset: Sendable {
    public struct Instance: Sendable {
        public let duplicateID: Int
        public let delay: TimeInterval

        init(definition: CylinderEffectDefinition, duplicateID: Int) {
            self.duplicateID = duplicateID

            self.delay = definition.delayStart
                + definition.delayOffset
                + definition.duplicate.delayOffsetDelta * TimeInterval(duplicateID)
                + definition.delayLate
                + definition.duplicate.delayLateDelta * TimeInterval(duplicateID)
                + definition.duplicate.interval * TimeInterval(duplicateID)
        }
    }

    public let definition: CylinderEffectDefinition
    public let rotationDegrees: SIMD3<Float>
    public let vertices: [CylinderEffectVertex]
    public let textureImage: CGImage

    public func makeInstances() -> [CylinderEffectAsset.Instance] {
        (0..<max(definition.duplicate.count, 1)).map { duplicateID in
            CylinderEffectAsset.Instance(definition: definition, duplicateID: duplicateID)
        }
    }

    static func load(with definition: CylinderEffectDefinition, using resourceManager: ResourceManager) async throws -> CylinderEffectAsset {
        var rotationDegrees = definition.rotationDegrees
        if let range = definition.rotationXRandomRange {
            rotationDegrees.x += Float.random(in: range)
        }
        if let range = definition.rotationYRandomRange {
            rotationDegrees.y += Float.random(in: range)
        }
        if let range = definition.rotationZRandomRange {
            rotationDegrees.z += Float.random(in: range)
        }

        let texturePath = ResourcePath.effectDirectory
            .appending(definition.textureName)
            .appendingPathExtension("tga")
        let image = try await resourceManager.image(at: texturePath)

        let asset = CylinderEffectAsset(
            definition: definition,
            rotationDegrees: rotationDegrees,
            vertices: makeVertices(
                totalCircleSides: definition.totalCircleSides,
                visibleCircleSides: definition.visibleCircleSides,
                textureRepeatX: definition.textureRepeatX
            ),
            textureImage: image.cgImage
        )
        return asset
    }

    private static func makeVertices(
        totalCircleSides: Int,
        visibleCircleSides: Int,
        textureRepeatX: Float
    ) -> [CylinderEffectVertex] {
        let totalCircleSides = max(totalCircleSides, 3)
        let visibleCircleSides = max(min(visibleCircleSides, totalCircleSides), 1)

        func vertex(side: Int, top: Bool) -> CylinderEffectVertex {
            let circleFraction = Float(side) / Float(totalCircleSides)
            let angle = circleFraction * 2 * Float.pi
            let textureU = circleFraction * Float(totalCircleSides) / Float(visibleCircleSides) * textureRepeatX
            return CylinderEffectVertex(
                position: [sin(angle), cos(angle), top ? 1 : 0],
                textureCoordinate: [textureU, top ? 0 : 1]
            )
        }

        var vertices: [CylinderEffectVertex] = []
        vertices.reserveCapacity(visibleCircleSides * 6)

        for side in 0..<visibleCircleSides {
            let bottom0 = vertex(side: side, top: false)
            let top0 = vertex(side: side, top: true)
            let bottom1 = vertex(side: side + 1, top: false)
            let top1 = vertex(side: side + 1, top: true)

            vertices.append(bottom0)
            vertices.append(top0)
            vertices.append(bottom1)
            vertices.append(top0)
            vertices.append(bottom1)
            vertices.append(top1)
        }

        return vertices
    }
}
