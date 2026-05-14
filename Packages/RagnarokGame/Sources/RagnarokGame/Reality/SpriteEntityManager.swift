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

    private var entitiesByObjectID: [GameObjectID : EntityPhase] = [:]
    private var templateEntitiesByJobID: [Int : EntityPhase] = [:]

    init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager
    }

    func addEntity(_ entity: Entity, for objectID: GameObjectID) {
        entitiesByObjectID[objectID] = .loaded(entity)
    }

    func removeEntity(for objectID: GameObjectID) async throws {
        if let phase = entitiesByObjectID[objectID] {
            let entity = try await phase.entity
            entity.removeFromParent()
            entitiesByObjectID.removeValue(forKey: objectID)
        }
    }

    func findEntity(for objectID: GameObjectID) async throws -> Entity? {
        if let phase = entitiesByObjectID[objectID] {
            try await phase.entity
        } else {
            nil
        }
    }

    func entity(for mapObject: MapObject) async throws -> (entity: Entity, isNew: Bool) {
        let job = SpriteJob(rawValue: mapObject.job)
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
            try await Entity(from: mapObject, using: resourceManager)
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
            try await Entity(from: mapObject, using: resourceManager)
        }

        templateEntitiesByJobID[mapObject.job] = .inProgress(templateTask)

        let templateEntity = try await templateTask.value

        templateEntitiesByJobID[mapObject.job] = .loaded(templateEntity)

        let clonedEntity = templateEntity.clone(recursive: true)

        entitiesByObjectID[mapObject.objectID] = .loaded(clonedEntity)

        return (clonedEntity, true)
    }
}
