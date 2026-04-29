//
//  WorldEntity.swift
//  RagnarokRealityRendering
//
//  Created by Leon Li on 2025/2/26.
//

import Foundation
import RagnarokCore
import RagnarokRenderAssets
import RagnarokResources
import RealityKit

extension Entity {
    public convenience init(from world: WorldResource, resourceManager: ResourceManager, progress: Progress) async throws {
        self.init()

        let worldAssetLoader = WorldAssetLoader()

        metric.beginMeasuring("Load world assets")

        let worldAsset = try await worldAssetLoader.load(
            gat: world.gat,
            gnd: world.gnd,
            rsw: world.rsw,
            resourceManager: resourceManager,
            progress: progress
        )

        metric.endMeasuring("Load world assets")

        // MARK: - Ground Entity

        metric.beginMeasuring("Load ground entity")

        let groundEntity = try await Entity(from: worldAsset.ground)
        addChild(groundEntity, preservingWorldTransform: true)

        metric.endMeasuring("Load ground entity")

        // MARK: - Water Entity

        let waterEntity = try await Entity(from: worldAsset.water)
        addChild(waterEntity, preservingWorldTransform: true)

        // MARK: - Prototype Model Entities

        metric.beginMeasuring("Load prototype model entities")

        var modelEntitiesByName: [String : Entity] = [:]
        for modelGroup in worldAsset.modelGroups {
            do {
                let modelEntity = try await Entity(from: modelGroup.prototype)
                modelEntitiesByName[modelGroup.prototype.name] = modelEntity
            } catch {
                logger.warning("\(error)")
            }
        }

        metric.endMeasuring("Load prototype model entities")

        // MARK: - Model Entities

        metric.beginMeasuring("Load model entities")

        for modelGroup in worldAsset.modelGroups {
            guard let modelEntity = modelEntitiesByName[modelGroup.prototype.name] else {
                continue
            }

            for instance in modelGroup.instances {
                let clonedModelEntity = modelEntity.clone(recursive: true)

                clonedModelEntity.position = instance.position
                clonedModelEntity.orientation =
                    simd_quatf(angle: radians(instance.rotation.z), axis: [0, 0, 1]) *
                    simd_quatf(angle: radians(instance.rotation.x), axis: [1, 0, 0]) *
                    simd_quatf(angle: radians(instance.rotation.y), axis: [0, 1, 0])
                clonedModelEntity.scale = instance.scale

                addChild(clonedModelEntity, preservingWorldTransform: true)
            }
        }

        metric.endMeasuring("Load model entities")
    }
}
