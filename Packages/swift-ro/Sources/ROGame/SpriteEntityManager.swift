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

    private var entitiesByJobID: [Int : SpriteEntity] = [:]

    public init(resourceManager: ResourceManager, scriptManager: ScriptManager) {
        self.resourceManager = resourceManager
        self.scriptManager = scriptManager
    }

    public func entity(for mapObject: MapObject) async -> SpriteEntity? {
        if let entity = entitiesByJobID[mapObject.job] {
            let entityClone = await entity.clone(recursive: true)
            return entityClone
        }

        do {
            let configuration = ComposedSprite.Configuration(mapObject: mapObject)
            let composedSprite = await ComposedSprite(
                configuration: configuration,
                resourceManager: resourceManager,
                scriptManager: scriptManager
            )
            let actions = try await SpriteAction.actions(for: composedSprite)
            let entity = await SpriteEntity(actions: actions)

            if !configuration.job.isPlayer {
                entitiesByJobID[mapObject.job] = entity
            }

            return entity
        } catch {
            return nil
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
