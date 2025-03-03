//
//  Entity+World.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/26.
//

import RealityKit
import RORenderers
import RORendering
import ROResources

extension Entity {
    public static func worldEntity(world: WorldResource) async throws -> Entity {
        let groundEntity = try await Entity.loadGround(gat: world.gat, gnd: world.gnd) { textureName in
            let components = textureName.split(separator: "\\").map(String.init)
            let texturePath = ResourcePath.texturePath.appending(components: components)
            let texture = try await ResourceManager.default.image(at: texturePath)
            return texture
        }

        var modelEntitiesByName: [String : Entity] = [:]

        for model in world.rsw.models {
            let modelName = model.modelName
            if modelEntitiesByName[modelName] == nil {
                let components = modelName.split(separator: "\\").map(String.init)
                let modelPath = ResourcePath.modelPath.appending(components: components)
                let model = try await ResourceManager.default.model(at: modelPath)
                if let modelEntity = try? await Entity.modelEntity(model: model) {
                    modelEntitiesByName[modelName] = modelEntity
                }
            }

            guard let modelEntity = modelEntitiesByName[model.modelName] else {
                continue
            }

            let modelEntityClone = modelEntity.clone(recursive: true)

            modelEntityClone.position = [
                model.position.x + Float(world.gnd.width),
                model.position.y,
                model.position.z + Float(world.gnd.height),
            ]
            modelEntityClone.orientation = simd_quatf(angle: radians(model.rotation.z), axis: [0, 0, 1]) * simd_quatf(angle: radians(model.rotation.x), axis: [1, 0, 0]) * simd_quatf(angle: radians(model.rotation.y), axis: [0, 1, 0])
            modelEntityClone.scale = model.scale

            groundEntity.addChild(modelEntityClone)
        }

        return groundEntity
    }
}
