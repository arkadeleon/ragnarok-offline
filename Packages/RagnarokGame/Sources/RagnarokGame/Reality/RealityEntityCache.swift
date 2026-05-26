//
//  RealityEntityCache.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

import RagnarokConstants
import RagnarokModels
import RagnarokResources
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
    private struct ObjectEntityEntry {
        var configuration: ComposedSprite.Configuration
        var phase: RealityEntityPhase
    }

    private let resourceManager: ResourceManager

    private var objectEntities: [GameObjectID : ObjectEntityEntry] = [:]
    private(set) var itemEntities: [GameObjectID : Entity] = [:]

    private var templateEntitiesByConfiguration: [ComposedSprite.Configuration : RealityEntityPhase] = [:]
    private var templateEntitiesByItemID: [Int : RealityEntityPhase] = [:]

    var objectIDs: Set<GameObjectID> {
        Set(objectEntities.keys)
    }

    init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager
    }

    func objectEntity(for objectID: GameObjectID) async throws -> Entity? {
        if let entry = objectEntities[objectID] {
            try await entry.phase.entity
        } else {
            nil
        }
    }

    func loadedObjectEntity(for objectID: GameObjectID) -> Entity? {
        guard let entry = objectEntities[objectID] else {
            return nil
        }

        switch entry.phase {
        case .loaded(let entity):
            return entity
        case .inProgress:
            return nil
        }
    }

    func removeObjectEntity(for objectID: GameObjectID) async throws {
        if let entry = objectEntities.removeValue(forKey: objectID) {
            let entity = try await entry.phase.entity
            entity.removeFromParent()
        }
    }

    func objectEntity(for object: MapSceneObject) async throws -> (entity: Entity, isNew: Bool) {
        let configuration = ComposedSprite.Configuration(object: object)

        if let entry = objectEntities[object.objectID] {
            if entry.configuration == configuration {
                return try await (entry.phase.entity, false)
            }

            removeObjectEntity(entry)
            objectEntities.removeValue(forKey: object.objectID)
        }

        if configuration.job.isPlayer {
            return try await playerEntity(
                for: object.objectID,
                configuration: configuration
            )
        } else {
            return try await nonPlayerEntity(
                for: object.objectID,
                configuration: configuration
            )
        }
    }

    private func playerEntity(
        for objectID: GameObjectID,
        configuration: ComposedSprite.Configuration
    ) async throws -> (entity: Entity, isNew: Bool) {
        let task = Task {
            try await Entity(configuration: configuration, using: resourceManager)
        }
        objectEntities[objectID] = ObjectEntityEntry(configuration: configuration, phase: .inProgress(task))

        let entity = try await task.value
        guard objectEntities[objectID]?.configuration == configuration else {
            entity.removeFromParent()
            throw CancellationError()
        }

        objectEntities[objectID] = ObjectEntityEntry(configuration: configuration, phase: .loaded(entity))

        return (entity, true)
    }

    private func nonPlayerEntity(
        for objectID: GameObjectID,
        configuration: ComposedSprite.Configuration
    ) async throws -> (entity: Entity, isNew: Bool) {
        if let templatePhase = templateEntitiesByConfiguration[configuration] {
            let cloneTask = Task {
                let templateEntity = try await templatePhase.entity
                return templateEntity.clone(recursive: true)
            }
            objectEntities[objectID] = ObjectEntityEntry(configuration: configuration, phase: .inProgress(cloneTask))

            let clonedEntity = try await cloneTask.value
            guard objectEntities[objectID]?.configuration == configuration else {
                clonedEntity.removeFromParent()
                throw CancellationError()
            }

            objectEntities[objectID] = ObjectEntityEntry(configuration: configuration, phase: .loaded(clonedEntity))

            return (clonedEntity, true)
        }

        let templateTask = Task {
            try await Entity(configuration: configuration, using: resourceManager)
        }
        templateEntitiesByConfiguration[configuration] = .inProgress(templateTask)
        let cloneTask = Task {
            let templateEntity = try await templateTask.value
            return templateEntity.clone(recursive: true)
        }
        objectEntities[objectID] = ObjectEntityEntry(configuration: configuration, phase: .inProgress(cloneTask))

        let templateEntity = try await templateTask.value
        templateEntitiesByConfiguration[configuration] = .loaded(templateEntity)

        let clonedEntity = try await cloneTask.value
        guard objectEntities[objectID]?.configuration == configuration else {
            clonedEntity.removeFromParent()
            throw CancellationError()
        }

        objectEntities[objectID] = ObjectEntityEntry(configuration: configuration, phase: .loaded(clonedEntity))

        return (clonedEntity, true)
    }

    private func removeObjectEntity(_ entry: ObjectEntityEntry) {
        switch entry.phase {
        case .inProgress(let task):
            task.cancel()
        case .loaded(let entity):
            entity.removeFromParent()
        }
    }

    func itemEntity(for item: MapSceneItem) -> Entity {
        if let entity = itemEntities[item.objectID] {
            return entity
        }

        let entity = Entity()
        itemEntities[item.objectID] = entity
        return entity
    }

    func removeItemEntity(for objectID: GameObjectID) {
        if let entity = itemEntities.removeValue(forKey: objectID) {
            entity.removeFromParent()
        }
    }

    func itemSpriteEntity(forItemID itemID: Int) async throws -> Entity {
        if let templatePhase = templateEntitiesByItemID[itemID] {
            let templateEntity = try await templatePhase.entity
            return templateEntity.clone(recursive: true)
        }

        let templateTask = Task<Entity, any Error> {
            let spriteEntity = try await SpriteEntity(forItemID: itemID, using: resourceManager)
            spriteEntity.name = "sprite"
            return spriteEntity
        }
        templateEntitiesByItemID[itemID] = .inProgress(templateTask)

        do {
            let templateEntity = try await templateTask.value
            templateEntitiesByItemID[itemID] = .loaded(templateEntity)
            return templateEntity.clone(recursive: true)
        } catch {
            templateEntitiesByItemID.removeValue(forKey: itemID)
            throw error
        }
    }

    func clear() {
        for entry in objectEntities.values {
            switch entry.phase {
            case .inProgress(let task):
                task.cancel()
            case .loaded(let entity):
                entity.removeFromParent()
            }
        }

        for entity in itemEntities.values {
            entity.removeFromParent()
        }

        for phase in templateEntitiesByConfiguration.values {
            if case .inProgress(let task) = phase {
                task.cancel()
            }
        }

        for phase in templateEntitiesByItemID.values {
            if case .inProgress(let task) = phase {
                task.cancel()
            }
        }

        objectEntities.removeAll()
        itemEntities.removeAll()
        templateEntitiesByConfiguration.removeAll()
        templateEntitiesByItemID.removeAll()
    }
}
