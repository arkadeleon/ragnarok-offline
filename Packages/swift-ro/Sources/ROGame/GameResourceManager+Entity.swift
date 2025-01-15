//
//  EntityLoader.swift
//  swift-ro
//
//  Created by Leon Li on 2025/1/14.
//

import RealityKit
import ROFileFormats
import RORenderers

extension GameResourceManager {
    @MainActor
    public func worldEntity(mapName: String) async throws -> Entity {
        let gat = try await gat(forMapName: mapName)
        let gnd = try await gnd(forMapName: mapName)
        let rsw = try await rsw(forMapName: mapName)

        let groundEntity = try await Entity.loadGround(gat: gat, gnd: gnd) { textureName in
            try await image(forTextureNamed: textureName)
        }

        var modelEntitiesByName: [String : Entity] = [:]

        for model in rsw.models {
            if modelEntitiesByName[model.modelName] == nil {
                if let modelEntity = try? await modelEntity(modelName: model.modelName) {
                    modelEntitiesByName[model.modelName] = modelEntity
                }
            }

            guard let modelEntity = modelEntitiesByName[model.modelName] else {
                continue
            }

            let modelEntityClone = modelEntity.clone(recursive: true)

            modelEntityClone.position = [
                model.position.x + Float(gnd.width),
                model.position.y,
                model.position.z + Float(gnd.height),
            ]
            modelEntityClone.orientation = simd_quatf(angle: radians(model.rotation.z), axis: [0, 0, 1]) * simd_quatf(angle: radians(model.rotation.x), axis: [1, 0, 0]) * simd_quatf(angle: radians(model.rotation.y), axis: [0, 1, 0])
            modelEntityClone.scale = model.scale

            groundEntity.addChild(modelEntityClone)
        }

        return groundEntity
    }

    @MainActor
    public func modelEntity(modelName: String) async throws -> Entity {
        let rsm = try await rsm(forModelName: modelName)

        let instance = Model.createInstance(
            position: .zero,
            rotation: .zero,
            scale: .one,
            width: 0,
            height: 0
        )

        let modelEntity = try await Entity.loadModel(rsm: rsm, instance: instance) { textureName in
            let texture = try await image(forTextureNamed: textureName)
            return texture?.removingMagentaPixels()
        }

        return modelEntity
    }
}
