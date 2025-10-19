//
//  SpriteEntityManager.swift
//  GameCore
//
//  Created by Leon Li on 2025/3/18.
//

import Constants
import NetworkClient
import NetworkPackets
import RealityKit
import ResourceManagement
import SpriteRendering

@MainActor
final class SpriteEntityManager {
    let resourceManager: ResourceManager

    private var playerEntitiesByObjectID: [UInt32 : Task<SpriteEntity, any Error>] = [:]
    private var nonPlayerEntitiesByJobID: [Int : Task<SpriteEntity, any Error>] = [:]

    init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager
    }

    func entity(for mapObject: MapObject) async throws -> SpriteEntity {
        let job = CharacterJob(rawValue: mapObject.job)
        if job.isPlayer {
            return try await playerEntity(for: mapObject)
        } else {
            return try await nonPlayerEntity(for: mapObject)
        }
    }

    func playerEntity(for mapObject: MapObject) async throws -> SpriteEntity {
        if let task = playerEntitiesByObjectID[mapObject.objectID] {
            return try await task.value
        }

        let task = Task {
            let configuration = ComposedSprite.Configuration(mapObject: mapObject)
            let composedSprite = try await ComposedSprite(configuration: configuration, resourceManager: resourceManager)
            let animations = try await SpriteAnimation.animations(for: composedSprite)
            let entity = SpriteEntity(animations: animations)
            return entity
        }

        playerEntitiesByObjectID[mapObject.objectID] = task

        return try await task.value
    }

    func nonPlayerEntity(for mapObject: MapObject) async throws -> SpriteEntity {
        if let task = nonPlayerEntitiesByJobID[mapObject.job] {
            let entity = try await task.value
            let entityClone = entity.clone(recursive: true)
            return entityClone
        }

        let task = Task {
            let configuration = ComposedSprite.Configuration(mapObject: mapObject)
            let composedSprite = try await ComposedSprite(configuration: configuration, resourceManager: resourceManager)
            let animations = try await SpriteAnimation.animations(for: composedSprite)
            let entity = SpriteEntity(animations: animations)
            return entity
        }

        nonPlayerEntitiesByJobID[mapObject.job] = task

        return try await task.value
    }
}

extension ComposedSprite.Configuration {
    init(char: CharInfo) {
        self.init(jobID: Int(char.job))
        self.gender = Gender(rawValue: Int(char.sex)) ?? .female
        self.hairStyle = Int(char.head)
        self.hairColor = Int(char.headPalette)
        self.clothesColor = Int(char.bodyPalette)
        self.weapon = Int(char.weapon)
        self.shield = Int(char.shield)
        self.headgears = [Int(char.accessory2), Int(char.accessory3), Int(char.accessory)]
        self.garment = Int(char.robePalette)

        self.updateHairStyle()
    }

    init(mapObject: MapObject) {
        self.init(jobID: mapObject.job)
        self.gender = mapObject.gender
        self.hairStyle = mapObject.hairStyle
        self.hairColor = mapObject.hairColor
        self.clothesColor = mapObject.clothesColor
        self.weapon = mapObject.weapon
        self.shield = mapObject.shield
        self.headgears = [mapObject.headTop, mapObject.headMid, mapObject.headBottom]
        self.garment = mapObject.garment

        self.updateHairStyle()
    }

    mutating func updateHairStyle() {
        let hairStyles: [Int] = if job.isDoram {
            switch gender {
            case .female: [0, 1, 2, 3, 4, 5, 6]
            case .male: [0, 1, 2, 3, 4, 5, 6]
            default: []
            }
        } else {
            switch gender {
            case .female: [2, 2, 4, 7, 1, 5, 3, 6, 12, 10, 9, 11, 8]
            case .male: [2, 2, 1, 7, 5, 4, 3, 6, 8, 9, 10, 12, 11]
            default: []
            }
        }

        let hairStyle = self.hairStyle
        if 0..<hairStyles.count ~= hairStyle {
            self.hairStyle = hairStyles[hairStyle]
        }
    }
}
