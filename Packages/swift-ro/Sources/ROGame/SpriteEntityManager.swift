//
//  SpriteEntityManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/18.
//

import RealityKit
import RONetwork
import RORendering
import ROResources

public actor SpriteEntityManager {
    package let resourceManager: ResourceManager
    package let scriptManager: ScriptManager

    private var tasksByJobID: [Int : Task<SpriteEntity, any Error>] = [:]

    public init(resourceManager: ResourceManager, scriptManager: ScriptManager) {
        self.resourceManager = resourceManager
        self.scriptManager = scriptManager
    }

    public func entity(for mapObject: MapObject) async throws -> SpriteEntity {
        if let task = tasksByJobID[mapObject.job] {
            let entity = try await task.value
            let entityClone = await entity.clone(recursive: true)
            return entityClone
        }

        let configuration = ComposedSprite.Configuration(mapObject: mapObject)
        let task = Task {
            let composedSprite = await ComposedSprite(
                configuration: configuration,
                resourceManager: resourceManager,
                scriptManager: scriptManager
            )
            let animations = try await SpriteAnimation.animations(for: composedSprite)
            let entity = await SpriteEntity(animations: animations)
            return entity
        }

        if configuration.job.isPlayer {
            return try await task.value
        } else {
            tasksByJobID[mapObject.job] = task
            return try await task.value
        }
    }
}

extension ComposedSprite.Configuration {
    public init(mapObject: MapObject) {
        let job = UniformJob(rawValue: mapObject.job)

        let hairStyles: [Int] = if job.isDoram {
            switch mapObject.gender {
            case .female: [0, 1, 2, 3, 4, 5, 6]
            case .male: [0, 1, 2, 3, 4, 5, 6]
            default: []
            }
        } else {
            switch mapObject.gender {
            case .female: [2, 2, 4, 7, 1, 5, 3, 6, 12, 10, 9, 11, 8]
            case .male: [2, 2, 1, 7, 5, 4, 3, 6, 8, 9, 10, 12, 11]
            default: []
            }
        }

        let hairStyle = if 0..<hairStyles.count ~= mapObject.hairStyle {
            hairStyles[mapObject.hairStyle]
        } else {
            mapObject.hairStyle
        }

        self.init(jobID: mapObject.job)
        self.gender = mapObject.gender
        self.hairStyle = hairStyle
        self.hairColor = mapObject.hairColor
        self.clothesColor = mapObject.clothesColor
        self.weapon = mapObject.weapon
        self.shield = mapObject.shield
        self.headgears = [mapObject.headTop, mapObject.headMid, mapObject.headBottom]
        self.garment = mapObject.garment
    }
}
