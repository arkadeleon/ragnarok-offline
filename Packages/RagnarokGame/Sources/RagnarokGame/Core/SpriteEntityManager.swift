//
//  SpriteEntityManager.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/3/18.
//

import RagnarokConstants
import RagnarokModels
import RagnarokResources
import RagnarokSprite
import RealityKit

@MainActor
final class SpriteEntityManager {
    let resourceManager: ResourceManager

    /// The current phase of the entity loading operation.
    enum EntityPhase {
        case inProgress(Task<Entity, any Error>)
        case loaded(Entity)

        var entity: Entity {
            get async throws {
                switch self {
                case .inProgress(let task):
                    try await task.value
                case .loaded(let entity):
                    entity
                }
            }
        }
    }

    private var entitiesByObjectID: [UInt32 : EntityPhase] = [:]
    private var templateEntitiesByJobID: [Int : EntityPhase] = [:]

    init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager
    }

    func addEntity(_ entity: Entity, forObjectID objectID: UInt32) {
        entitiesByObjectID[objectID] = .loaded(entity)
    }

    func removeEntity(forObjectID objectID: UInt32) async throws {
        if let phase = entitiesByObjectID[objectID] {
            let entity = try await phase.entity
            entity.removeFromParent()
            entitiesByObjectID.removeValue(forKey: objectID)
        }
    }

    func entity(forOjectID objectID: UInt32) async throws -> Entity? {
        if let phase = entitiesByObjectID[objectID] {
            return try await phase.entity
        } else {
            return nil
        }
    }

    func entity(for mapObject: MapObject) async throws -> (entity: Entity, isNew: Bool) {
        let job = CharacterJob(rawValue: mapObject.job)
        if job.isPlayer {
            return try await playerEntity(for: mapObject)
        } else {
            return try await nonPlayerEntity(for: mapObject)
        }
    }

    func playerEntity(for mapObject: MapObject) async throws -> (entity: Entity, isNew: Bool) {
        if let phase = entitiesByObjectID[mapObject.objectID] {
            return try await (phase.entity, false)
        }

        let task = Task {
            try await Entity(from: mapObject, resourceManager: resourceManager)
        }

        entitiesByObjectID[mapObject.objectID] = .inProgress(task)

        let entity = try await task.value

        entitiesByObjectID[mapObject.objectID] = .loaded(entity)

        return (entity, true)
    }

    func nonPlayerEntity(for mapObject: MapObject) async throws -> (entity: Entity, isNew: Bool) {
        if let phase = entitiesByObjectID[mapObject.objectID] {
            return try await (phase.entity, false)
        }

        if let templatePhase = templateEntitiesByJobID[mapObject.job] {
            let cloneTask = Task {
                let templateEntity = try await templatePhase.entity
                let clonedEntity = templateEntity.clone(recursive: true)
                return clonedEntity
            }

            entitiesByObjectID[mapObject.objectID] = .inProgress(cloneTask)

            let clonedEntity = try await cloneTask.value

            entitiesByObjectID[mapObject.objectID] = .loaded(clonedEntity)

            return (clonedEntity, true)
        }

        let templateTask = Task {
            try await Entity(from: mapObject, resourceManager: resourceManager)
        }

        templateEntitiesByJobID[mapObject.job] = .inProgress(templateTask)

        let templateEntity = try await templateTask.value

        templateEntitiesByJobID[mapObject.job] = .loaded(templateEntity)

        let clonedEntity = templateEntity.clone(recursive: true)

        entitiesByObjectID[mapObject.objectID] = .loaded(clonedEntity)

        return (clonedEntity, true)
    }
}

extension ComposedSprite.Configuration {
    init(character: CharacterInfo) {
        self.init(jobID: character.job)
        self.gender = Gender(rawValue: character.sex) ?? .female
        self.hairStyle = character.head
        self.hairColor = character.headPalette
        self.clothesColor = character.bodyPalette
        self.weapon = character.weapon
        self.shield = character.shield
        self.headgears = [character.accessory2, character.accessory3, character.accessory]
        self.garment = character.robePalette

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
