//
//  WorldEntity.swift
//  RagnarokReality
//
//  Created by Leon Li on 2025/2/26.
//

import Foundation
import RagnarokRenderers
import RagnarokResources
import RealityKit
import SGLMath

extension Entity {
    public convenience init(from world: WorldResource, resourceManager: ResourceManager, progress: Progress) async throws {
        self.init()

        // MARK: - RSM Models

        metric.beginMeasuring("Load rsm models")

        let uniqueModelNames = Set(world.rsw.models.map({ $0.modelName }))
        let models = await resourceManager.models(forNames: uniqueModelNames)

        metric.endMeasuring("Load rsm models")

        // MARK: - Textures

        metric.beginMeasuring("Load textures")

        var modelTextureNames: Set<String> = []
        for (_, model) in models {
            for node in model.rsm.nodes {
                modelTextureNames.formUnion(node.textures)
            }
        }

        progress.totalUnitCount = Int64(world.gnd.textures.count + modelTextureNames.count)
        progress.completedUnitCount = 0

        let groundTextures = await resourceManager.textures(forNames: world.gnd.textures, removesMagentaPixels: false) { _, _ in
            progress.completedUnitCount += 1
        }

        let modelTextures = await resourceManager.textures(forNames: modelTextureNames, removesMagentaPixels: true) { _, _ in
            progress.completedUnitCount += 1
        }

        metric.endMeasuring("Load textures")

        // MARK: - Ground Entity

        metric.beginMeasuring("Load ground entity")

        let ground = Ground(gat: world.gat, gnd: world.gnd)
        let groundEntity = try await Entity(from: ground, textures: groundTextures)
        addChild(groundEntity, preservingWorldTransform: true)

        metric.endMeasuring("Load ground entity")

        // MARK: - Water Entity

        let water = Water(gnd: world.gnd, rsw: world.rsw)
        let waterEntity = try await Entity(from: water, resourceManager: resourceManager)
        addChild(waterEntity, preservingWorldTransform: true)

        // MARK: - Prototype Model Entities

        metric.beginMeasuring("Load prototype model entities")

        let modelEntitiesByName = await withTaskGroup(
            of: Entity?.self,
            returning: [String : Entity].self
        ) { taskGroup in
            for (modelName, model) in models {
                taskGroup.addTask {
                    do {
                        let modelEntity = try await Entity(from: model, name: modelName, textures: modelTextures)
                        return modelEntity
                    } catch {
                        logger.warning("\(error)")
                        return nil
                    }
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
