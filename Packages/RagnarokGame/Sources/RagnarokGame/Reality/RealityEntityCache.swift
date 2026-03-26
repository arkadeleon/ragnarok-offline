//
//  RealityEntityCache.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

import RagnarokConstants
import RagnarokModels
import RagnarokSprite
import RealityKit

enum RealityEntityPhase {
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

@MainActor
final class RealityEntityCache {
    private let factory: RealitySpriteNodeFactory

    private var objectEntities: [GameObjectID : RealityEntityPhase] = [:]
    private var itemEntities: [GameObjectID : RealityEntityPhase] = [:]
    private var templateEntitiesByJobID: [Int : RealityEntityPhase] = [:]

    var objectIDs: Set<GameObjectID> {
        Set(objectEntities.keys)
    }

    var itemIDs: Set<GameObjectID> {
        Set(itemEntities.keys)
    }

    init(factory: RealitySpriteNodeFactory) {
        self.factory = factory
    }

    func addObjectEntity(_ entity: Entity, for objectID: GameObjectID) {
        objectEntities[objectID] = .loaded(entity)
    }

    func objectEntity(for objectID: GameObjectID) async throws -> Entity? {
        if let phase = objectEntities[objectID] {
            try await phase.entity
        } else {
            nil
        }
    }

    func loadedObjectEntity(for objectID: GameObjectID) -> Entity? {
        guard let phase = objectEntities[objectID] else {
            return nil
        }

        switch phase {
        case .loaded(let entity):
            return entity
        case .inProgress:
            return nil
        }
    }

    func removeObjectEntity(for objectID: GameObjectID) async throws {
        if let phase = objectEntities.removeValue(forKey: objectID) {
            let entity = try await phase.entity
            entity.removeFromParent()
        }
    }

    func objectEntity(for mapObject: MapObject) async throws -> (entity: Entity, isNew: Bool) {
        let job = CharacterJob(rawValue: mapObject.job)
        if job.isPlayer {
            return try await playerEntity(for: mapObject)
        } else {
            return try await nonPlayerEntity(for: mapObject)
        }
    }

    private func playerEntity(for mapObject: MapObject) async throws -> (entity: Entity, isNew: Bool) {
        if let phase = objectEntities[mapObject.objectID] {
            return try await (phase.entity, false)
        }

        let task = Task {
            try await factory.makeMapObjectEntity(for: mapObject)
        }
        objectEntities[mapObject.objectID] = .inProgress(task)

        let entity = try await task.value
        objectEntities[mapObject.objectID] = .loaded(entity)

        return (entity, true)
    }

    private func nonPlayerEntity(for mapObject: MapObject) async throws -> (entity: Entity, isNew: Bool) {
        if let phase = objectEntities[mapObject.objectID] {
            return try await (phase.entity, false)
        }

        if let templatePhase = templateEntitiesByJobID[mapObject.job] {
            let cloneTask = Task {
                let templateEntity = try await templatePhase.entity
                return templateEntity.clone(recursive: true)
            }
            objectEntities[mapObject.objectID] = .inProgress(cloneTask)

            let clonedEntity = try await cloneTask.value
            objectEntities[mapObject.objectID] = .loaded(clonedEntity)

            return (clonedEntity, true)
        }

        let templateTask = Task {
            try await factory.makeMapObjectEntity(for: mapObject)
        }
        templateEntitiesByJobID[mapObject.job] = .inProgress(templateTask)

        let templateEntity = try await templateTask.value
        templateEntitiesByJobID[mapObject.job] = .loaded(templateEntity)

        let clonedEntity = templateEntity.clone(recursive: true)
        objectEntities[mapObject.objectID] = .loaded(clonedEntity)

        return (clonedEntity, true)
    }

    func itemEntity(for mapItem: MapItem) async throws -> Entity {
        if let phase = itemEntities[mapItem.objectID] {
            return try await phase.entity
        }

        let task = Task {
            try await factory.makeMapItemEntity(for: mapItem)
        }
        itemEntities[mapItem.objectID] = .inProgress(task)

        let entity = try await task.value
        itemEntities[mapItem.objectID] = .loaded(entity)
        return entity
    }

    func removeItemEntity(for objectID: GameObjectID) async throws {
        if let phase = itemEntities.removeValue(forKey: objectID) {
            let entity = try await phase.entity
            entity.removeFromParent()
        }
    }
}
