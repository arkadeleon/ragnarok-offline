//
//  WorldEntity.swift
//  RagnarokReality
//
//  Created by Leon Li on 2025/2/26.
//

import Foundation
import RagnarokRenderers
import RagnarokResources
import RagnarokSceneAssets
import RealityKit
import SGLMath

extension Entity {
    public convenience init(from world: WorldResource, resourceManager: ResourceManager, progress: Progress) async throws {
        self.init()

        let worldAssetLoader = MapWorldAssetLoader()

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

        let groundEntity = try await Entity(
            from: worldAsset.ground.ground,
            lighting: worldAsset.lighting,
            textureImages: worldAsset.ground.textureImages
        )
        addChild(groundEntity, preservingWorldTransform: true)

        metric.endMeasuring("Load ground entity")

        // MARK: - Water Entity

        let waterEntity = try await Entity(from: worldAsset.water)
        addChild(waterEntity, preservingWorldTransform: true)

        // MARK: - Prototype Model Entities

        metric.beginMeasuring("Load prototype model entities")

        var modelEntitiesByName: [String : Entity] = [:]
        for modelAsset in worldAsset.models {
            do {
                let modelEntity = try await Entity(
                    from: modelAsset,
                    lighting: worldAsset.lighting
                )
                modelEntitiesByName[modelAsset.name] = modelEntity
            } catch {
                logger.warning("\(error)")
            }
        }

        metric.endMeasuring("Load prototype model entities")

        // MARK: - Model Entities

        metric.beginMeasuring("Load model entities")

        for modelAsset in worldAsset.models {
            guard let modelEntity = modelEntitiesByName[modelAsset.name] else {
                continue
            }

            for instance in modelAsset.instances {
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
