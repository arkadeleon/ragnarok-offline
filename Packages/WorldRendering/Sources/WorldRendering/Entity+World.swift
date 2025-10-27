//
//  Entity+World.swift
//  WorldRendering
//
//  Created by Leon Li on 2025/2/26.
//

import RealityKit
import RagnarokResources
import SGLMath

extension Entity {
    public static func worldEntity(world: WorldResource, resourceManager: ResourceManager) async throws -> Entity {
        metric.beginMeasuring("Load ground")

        let groundTextures = await resourceManager.textures(forNames: world.gnd.textures, removesMagentaPixels: false)
        let groundEntity = try await Entity.groundEntity(gat: world.gat, gnd: world.gnd, textures: groundTextures)

        metric.endMeasuring("Load ground")

        metric.beginMeasuring("Load models")

        let uniqueModelNames = Set(world.rsw.models.map({ $0.modelName }))
        let models = await resourceManager.models(forNames: uniqueModelNames)

        metric.endMeasuring("Load models")

        metric.beginMeasuring("Load model textures")

        var modelTextureNames: Set<String> = []
        for (_, model) in models {
            for node in model.rsm.nodes {
                modelTextureNames.formUnion(node.textures)
            }
        }
        let modelTextures = await resourceManager.textures(forNames: modelTextureNames, removesMagentaPixels: true)

        metric.endMeasuring("Load model textures")

        let waterEntity = try await Entity.waterEntity(gnd: world.gnd, rsw: world.rsw, resourceManager: resourceManager)
        groundEntity.addChild(waterEntity)

        metric.beginMeasuring("Load model entities")

        let modelEntitiesByName = await withTaskGroup(
            of: Entity?.self,
            returning: [String : Entity].self
        ) { taskGroup in
            for (modelName, model) in models {
                taskGroup.addTask {
                    let modelEntity = try? await Entity.modelEntity(model: model, name: modelName, textures: modelTextures)
                    return modelEntity
                }
            }

            var modelEntitiesByName: [String : Entity] = [:]
            for await modelEntity in taskGroup {
                if let modelEntity {
                    modelEntitiesByName[modelEntity.name] = modelEntity
                }
            }
            return modelEntitiesByName
        }

        metric.endMeasuring("Load model entities")

        for model in world.rsw.models {
            guard let modelEntity = modelEntitiesByName[model.modelName] else {
                continue
            }

            let modelEntityClone = modelEntity.clone(recursive: true)

            modelEntityClone.position = [
                model.position.x + Float(world.gnd.width),
                model.position.y,
                model.position.z + Float(world.gnd.height),
            ]
            modelEntityClone.orientation =
                simd_quatf(angle: radians(model.rotation.z), axis: [0, 0, 1]) *
                simd_quatf(angle: radians(model.rotation.x), axis: [1, 0, 0]) *
                simd_quatf(angle: radians(model.rotation.y), axis: [0, 1, 0])
            modelEntityClone.scale = model.scale

            groundEntity.addChild(modelEntityClone)
        }

        return groundEntity
    }
}
