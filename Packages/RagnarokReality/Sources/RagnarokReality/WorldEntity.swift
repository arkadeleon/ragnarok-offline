//
//  WorldEntity.swift
//  RagnarokReality
//
//  Created by Leon Li on 2025/2/26.
//

import RagnarokResources
import RealityKit
import SGLMath

extension Entity {
    public convenience init(from world: WorldResource, resourceManager: ResourceManager) async throws {
        self.init()

        // MARK: - Ground Entity

        metric.beginMeasuring("Load ground entity")

        let groundTextures = await resourceManager.textures(forNames: world.gnd.textures, removesMagentaPixels: false)
        let groundEntity = try await Entity.groundEntity(gat: world.gat, gnd: world.gnd, textures: groundTextures)
        addChild(groundEntity, preservingWorldTransform: true)

        metric.endMeasuring("Load ground entity")

        // MARK: - Models

        metric.beginMeasuring("Load models")

        let uniqueModelNames = Set(world.rsw.models.map({ $0.modelName }))
        let models = await resourceManager.models(forNames: uniqueModelNames)

        metric.endMeasuring("Load models")

        // MARK: - Model Textures

        metric.beginMeasuring("Load model textures")

        var modelTextureNames: Set<String> = []
        for (_, model) in models {
            for node in model.rsm.nodes {
                modelTextureNames.formUnion(node.textures)
            }
        }
        let modelTextures = await resourceManager.textures(forNames: modelTextureNames, removesMagentaPixels: true)

        metric.endMeasuring("Load model textures")

        // MARK: - Water Entity

        let waterEntity = try await Entity.waterEntity(gnd: world.gnd, rsw: world.rsw, resourceManager: resourceManager)
        addChild(waterEntity, preservingWorldTransform: true)

        // MARK: - Prototype Model Entities

        metric.beginMeasuring("Load prototype model entities")

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

        metric.endMeasuring("Load prototype model entities")

        // MARK: - Model Entities

        metric.beginMeasuring("Load model entities")

        for model in world.rsw.models {
            guard let modelEntity = modelEntitiesByName[model.modelName] else {
                continue
            }

            let clonedModelEntity = modelEntity.clone(recursive: true)

            clonedModelEntity.position = [
                model.position.x + Float(world.gnd.width),
                model.position.y,
                model.position.z + Float(world.gnd.height),
            ]
            clonedModelEntity.orientation =
                simd_quatf(angle: radians(model.rotation.z), axis: [0, 0, 1]) *
                simd_quatf(angle: radians(model.rotation.x), axis: [1, 0, 0]) *
                simd_quatf(angle: radians(model.rotation.y), axis: [0, 1, 0])
            clonedModelEntity.scale = model.scale

            addChild(clonedModelEntity, preservingWorldTransform: true)
        }

        metric.endMeasuring("Load model entities")
    }
}
