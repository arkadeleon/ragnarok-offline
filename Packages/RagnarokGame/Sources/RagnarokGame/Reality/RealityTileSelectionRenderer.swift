//
//  RealityTileSelectionRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

import RagnarokResources
import RealityKit
import simd

@MainActor
final class RealityTileSelectionRenderer {
    let entity = Entity()

    private let resourceManager: ResourceManager
    private var isPrepared = false

    init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager
    }

    func prepare() async {
        guard !isPrepared else {
            return
        }

        do {
            let path = ResourcePath.textureDirectory.appending(["grid.tga"])
            let image = try await resourceManager.image(at: path)

            let options = TextureResource.CreateOptions(semantic: .color)
            let texture = try await TextureResource(image: image.cgImage, withName: "tile.selector", options: options)

            var material = UnlitMaterial(texture: texture)
            material.blending = .transparent(opacity: 1.0)
            material.opacityThreshold = 0.0001

            entity.components.set(
                ModelComponent(mesh: .generatePlane(width: 1, height: 1), materials: [material])
            )
            entity.isEnabled = false
            isPrepared = true
        } catch {
            logger.warning("\(error)")
        }
    }

    func showSelection(at position: SIMD2<Int>, in mapGrid: MapGrid) {
        guard isPrepared else {
            return
        }

        let cell = mapGrid[position]

        let p0: SIMD3<Float> = [Float(position.x), cell.bottomLeftAltitude + 0.1, -Float(position.y)]
        let p1: SIMD3<Float> = [Float(position.x + 1), cell.bottomRightAltitude + 0.1, -Float(position.y)]
        let p2: SIMD3<Float> = [Float(position.x + 1), cell.topRightAltitude + 0.1, -Float(position.y + 1)]
        let p3: SIMD3<Float> = [Float(position.x), cell.topLeftAltitude + 0.1, -Float(position.y + 1)]

        let t0: SIMD2<Float> = [0, 0]
        let t1: SIMD2<Float> = [1, 0]
        let t2: SIMD2<Float> = [1, 1]
        let t3: SIMD2<Float> = [0, 1]

        var descriptor = MeshDescriptor(name: "tile.selector")
        descriptor.materials = .allFaces(0)
        descriptor.primitives = .triangles([0, 1, 2, 2, 3, 0])
        descriptor.positions = MeshBuffer([p0, p1, p2, p3])
        descriptor.textureCoordinates = MeshBuffer([t0, t1, t2, t3])

        Task {
            do {
                let mesh = try await MeshResource(from: [descriptor])
                entity.components[ModelComponent.self]?.mesh = mesh
                entity.isEnabled = true

                let disableEntityAction = SetEntityEnabledAction(isEnabled: false)
                let animation = try AnimationResource.makeActionAnimation(
                    for: disableEntityAction,
                    duration: 1 / 30,
                    delay: 0.5
                )
                entity.playAnimation(animation)
            } catch {
                logger.warning("\(error)")
            }
        }
    }

    func syncSelection(_ selectedPosition: SIMD2<Int>?, mapGrid: MapGrid) {
        guard let selectedPosition,
              0..<mapGrid.width ~= selectedPosition.x,
              0..<mapGrid.height ~= selectedPosition.y else {
            entity.isEnabled = false
            return
        }

        showSelection(at: selectedPosition, in: mapGrid)
    }
}
