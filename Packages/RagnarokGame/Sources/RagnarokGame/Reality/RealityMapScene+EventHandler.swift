//
//  RealityMapScene+EventHandler.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/6/1.
//

import AVFAudio
import RagnarokConstants
import RagnarokModels
import RagnarokResources
import RagnarokSprite
import RealityKit

extension RealityMapScene {
    public func onPlayerMoved(startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
        guard let playerEntity = objectEntities[player.objectID] else {
            return
        }

        let path = pathFinder.findPath(from: startPosition, to: endPosition)
        if path.count > 1 {
            playerEntity.components.set(WalkingComponent(path: path, mapGrid: mapGrid))
        }

        tileEntityManager?.updateTileEntities(forCenter: endPosition)
    }

    public func onPlayerStatusChanged(property: StatusProperty, value: Int) {
        guard let playerEntity = objectEntities[player.objectID] else {
            return
        }

        switch property {
        case .hp:
            playerEntity.components[HealthPointsComponent.self]?.hp = value
        case .maxhp:
            playerEntity.components[HealthPointsComponent.self]?.maxHp = value
        case .sp:
            playerEntity.components[SpellPointsComponent.self]?.sp = value
        case .maxsp:
            playerEntity.components[SpellPointsComponent.self]?.maxSp = value
        default:
            break
        }
    }

    public func onPlayerHealthPointsRecovered(recovered: Int, current: Int) {
        objectEntities[player.objectID]?.components[HealthPointsComponent.self]?.hp = current

        let combatText = MapSceneCombatText(
            creationTime: .now,
            target: MapSceneCombatText.Target(objectID: player.objectID, isPlayer: true),
            amount: recovered,
            kind: .hpRecovery,
            delay: .zero
        )
        addCombatText(combatText)
    }

    public func onPlayerSpellPointsRecovered(recovered: Int, current: Int) {
        objectEntities[player.objectID]?.components[SpellPointsComponent.self]?.sp = current

        let combatText = MapSceneCombatText(
            creationTime: .now,
            target: MapSceneCombatText.Target(objectID: player.objectID, isPlayer: true),
            amount: recovered,
            kind: .spRecovery,
            delay: .zero
        )
        addCombatText(combatText)
    }

    public func onMapObjectSpawned(object: MapObject, position: SIMD2<Int>, direction: Direction, headDirection: HeadDirection) {
        Task {
            let (entity, isNew) = try await spriteEntityManager.entity(for: object)
            if isNew {
                let worldPosition = mapGrid.worldPosition(for: position)
                entity.position = worldPosition
                entity.components.set(GridPositionComponent(position: position))
                entity.components.set(MapObjectComponent(object: object))
                entity.components.set(HealthPointsComponent(hp: object.hp, maxHp: object.maxHp))
                let spriteDirection = SpriteDirection(direction: direction)
                entity.playSpriteAnimation(.idle, direction: spriteDirection)
                rootEntity.addChild(entity)
            }
            objectEntities[object.objectID] = entity
        }
    }

    public func onMapObjectMoved(object: MapObject, startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
        Task {
            let (entity, isNew) = try await spriteEntityManager.entity(for: object)
            if isNew {
                let worldPosition = mapGrid.worldPosition(for: startPosition)
                entity.position = worldPosition
                entity.components.set(GridPositionComponent(position: startPosition))
                entity.components.set(MapObjectComponent(object: object))
                entity.components.set(HealthPointsComponent(hp: object.hp, maxHp: object.maxHp))
                rootEntity.addChild(entity)
            }
            objectEntities[object.objectID] = entity

            let path = pathFinder.findPath(from: startPosition, to: endPosition)
            if path.count > 1 {
                entity.components.set(WalkingComponent(path: path, mapGrid: mapGrid))
            }
        }
    }

    public func onMapObjectStopped(objectID: GameObjectID, position: SIMD2<Int>) {
        guard let entity = objectEntities[objectID] else {
            return
        }

        entity.components.remove(WalkingComponent.self)
        entity.components[GridPositionComponent.self]?.position = position
        entity.position = mapGrid.worldPosition(for: position)

        let direction = entity.findEntity(named: "sprite")?.components[SpriteActionComponent.self]?.direction ?? .south
        entity.playSpriteAnimation(.idle, direction: direction)
    }

    public func onMapObjectVanished(objectID: GameObjectID, type: UnitClearType) {
        switch type {
        case .dead where objectID == player.objectID:
            let direction = objectEntities[objectID]?.findEntity(named: "sprite")?.components[SpriteActionComponent.self]?.direction ?? .south
            objectEntities[objectID]?.playSpriteAnimation(.die, direction: direction)
        default:
            Task {
                try? await spriteEntityManager.removeEntity(for: objectID)
                objectEntities.removeValue(forKey: objectID)
            }
        }
    }

    public func onMapObjectResurrected(objectID: GameObjectID) {
        guard let entity = objectEntities[objectID] else {
            return
        }

        let direction = entity.findEntity(named: "sprite")?.components[SpriteActionComponent.self]?.direction ?? .south
        entity.playSpriteAnimation(.idle, direction: direction)
    }

    public func onMapObjectDirectionChanged(objectID: GameObjectID, direction: Direction, headDirection: HeadDirection) {
        guard let entity = objectEntities[objectID] else {
            return
        }

        let spriteDirection = SpriteDirection(direction: direction)
        entity.playSpriteAnimation(.idle, direction: spriteDirection)
    }

    public func onMapObjectSpriteChanged(objectID: GameObjectID, look: Look, value: Int, value2: Int) {
    }

    public func onMapObjectStateChanged(objectID: GameObjectID, bodyState: StatusChangeOption1, healthState: StatusChangeOption2, effectState: StatusChangeOption) {
        objectEntities[objectID]?.isEnabled = effectState != .cloak
    }

    public func onMapObjectActionPerformed(objectAction: MapObjectAction) {
        guard let entity = objectEntities[objectAction.sourceObjectID] else {
            return
        }

        let direction = entity.findEntity(named: "sprite")?.components[SpriteActionComponent.self]?.direction ?? .south

        switch objectAction.type {
        case .sit_down:
            entity.playSpriteAnimation(.sit, direction: direction)
        case .stand_up:
            entity.playSpriteAnimation(.idle, direction: direction)
        case .pickup_item:
            entity.playSpriteAnimation(.pickup, direction: direction, nextActionType: .idle)
        case .normal, .endure, .critical, .multi_hit, .multi_hit_endure, .multi_hit_critical, .lucy_dodge:
            entity.attack(direction: direction)
        default:
            break
        }

        addCombatTexts(for: objectAction)
        playAttackSounds(for: objectAction)
    }

    public func onMapObjectSkillPerformed(objectSkill: MapObjectSkill) {
        guard let entity = objectEntities[objectSkill.sourceObjectID] else {
            return
        }

        let direction = entity.findEntity(named: "sprite")?.components[SpriteActionComponent.self]?.direction ?? .south
        entity.castSkill(direction: direction)

        if objectSkill.isHealingSkill, let targetEntity = objectEntities[objectSkill.targetObjectID] {
            let isPlayer = targetEntity.components[MapObjectComponent.self]?.object.type == .pc
            let combatText = MapSceneCombatText(
                creationTime: .now,
                target: MapSceneCombatText.Target(objectID: objectSkill.targetObjectID, isPlayer: isPlayer),
                amount: objectSkill.level,
                kind: .hpRecovery,
                delay: .zero
            )
            addCombatText(combatText)

            playSound(named: "_heal_effect.wav", on: objectSkill.targetObjectID)
        }

        guard objectSkill.damage >= 0 else {
            return
        }

        let now = ContinuousClock.now
        let count = max(1, objectSkill.count)
        let damage = objectSkill.damage
        let isPlayer = objectEntities[objectSkill.targetObjectID]?.components[MapObjectComponent.self]?.object.type == .pc
        let target = MapSceneCombatText.Target(objectID: objectSkill.targetObjectID, isPlayer: isPlayer)
        for i in 0..<count {
            let combatText = MapSceneCombatText(
                creationTime: now,
                target: target,
                amount: damage / count,
                delay: .milliseconds(objectSkill.attackDelay) + .milliseconds(200 * i)
            )
            addCombatText(combatText)
        }
    }

    public func onMapObjectHealthUpdated(objectID: GameObjectID, hp: Int, maxHp: Int) {
        guard let entity = objectEntities[objectID] else {
            return
        }

        entity.components[HealthPointsComponent.self]?.hp = hp
        entity.components[HealthPointsComponent.self]?.maxHp = maxHp
    }

    public func onItemSpawned(item: MapItem, position: SIMD2<Int>) {
        Task {
            let itemEntity = Entity()
            itemEntity.position = mapGrid.worldPosition(for: position)
            itemEntity.components.set(GridPositionComponent(position: position))
            itemEntity.components.set(MapItemComponent(item: item))

            let spriteEntity = try await SpriteEntity(forItemID: Int(item.itemID), using: resourceManager)
            if let animation = spriteEntity.components[SpriteAnimationLibraryComponent.self]?.defaultAnimation {
                spriteEntity.setSpriteAnimation(animation)
                spriteEntity.generateModelAndCollisionShape(for: animation)
            }
            itemEntity.addChild(spriteEntity)

            rootEntity.addChild(itemEntity)
            itemEntities[item.objectID] = itemEntity
        }
    }

    public func onItemVanished(objectID: GameObjectID) {
        if let entity = itemEntities.removeValue(forKey: objectID) {
            entity.removeFromParent()
        }
    }

    public func onGroundSkillCast(skillID: SkillID, position: SIMD2<Int>) {
    }
}

// MARK: - Combat Text

extension RealityMapScene {
    private func addCombatText(_ combatText: MapSceneCombatText) {
        let entity = Entity.makeCombatTextEntity(for: combatText)
        if var component = entity.components[CombatTextComponent.self],
           let targetEntity = objectEntities[combatText.target.objectID] {
            component.targetEntityID = targetEntity.id
            entity.components.set(component)
        }
        rootEntity.addChild(entity)
    }

    private func addCombatTexts(for objectAction: MapObjectAction) {
        let now = ContinuousClock.now
        let isPlayer = objectEntities[objectAction.targetObjectID]?.components[MapObjectComponent.self]?.object.type == .pc
        let target = MapSceneCombatText.Target(objectID: objectAction.targetObjectID, isPlayer: isPlayer)
        let speed = objectAction.sourceSpeed

        switch objectAction.type {
        case .normal, .endure, .critical:
            addCombatText(MapSceneCombatText(
                creationTime: now,
                target: target,
                amount: objectAction.damage,
                delay: .milliseconds(speed)
            ))
            if objectAction.damage2 > 0 {
                addCombatText(MapSceneCombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage2,
                    delay: .milliseconds(speed) + .milliseconds(200 * 1.75)
                ))
            }
        case .multi_hit, .multi_hit_endure, .multi_hit_critical:
            let count = objectAction.damage > 1 ? 2 : 1
            if count == 2 {
                addCombatText(MapSceneCombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage / count,
                    delay: .milliseconds(speed)
                ))
            }
            if objectAction.damage2 > 0 {
                addCombatText(MapSceneCombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage / count,
                    delay: .milliseconds(speed) + .milliseconds(200 / 2)
                ))
                addCombatText(MapSceneCombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage2,
                    delay: .milliseconds(speed) + .milliseconds(200 * 1.75)
                ))
            } else {
                addCombatText(MapSceneCombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage / count,
                    delay: .milliseconds(speed) + .milliseconds(200)
                ))
            }
        default:
            break
        }
    }
}

// MARK: - Sound

extension RealityMapScene {
    private func playSound(named soundName: String, on objectID: GameObjectID) {
        Task { [weak self] in
            guard let resource = await self?.soundEffectResource(for: soundName) else {
                return
            }
            self?.objectEntities[objectID]?.playAudio(resource)
        }
    }

    private func playAttackSounds(for objectAction: MapObjectAction) {
        let isAttackAction: Bool = switch objectAction.type {
        case .normal, .endure, .critical, .multi_hit, .multi_hit_endure, .multi_hit_critical, .lucy_dodge: true
        default: false
        }
        guard isAttackAction else {
            return
        }

        let sourceObject = objectEntities[objectAction.sourceObjectID]?.components[MapObjectComponent.self]?.object
        let targetObject = objectEntities[objectAction.targetObjectID]?.components[MapObjectComponent.self]?.object

        if let sourceObject, SpriteJob(rawValue: sourceObject.job).isPlayer {
            let weaponType = WeaponType(rawValue: sourceObject.weapon) ?? .w_fist
            if let soundName = WeaponSoundTable.attackSoundNames(for: weaponType).randomElement() {
                playSound(named: soundName, on: objectAction.sourceObjectID)
            }
        }

        if let targetObject, objectAction.damage > 0 {
            let targetJob = SpriteJob(rawValue: targetObject.job)
            let hitSoundName: String?
            if targetJob.isPlayer {
                hitSoundName = JobHitSoundTable.hitSoundNames(forJob: targetObject.job).randomElement()
            } else if let sourceObject, SpriteJob(rawValue: sourceObject.job).isPlayer {
                let weaponType = WeaponType(rawValue: sourceObject.weapon) ?? .w_fist
                hitSoundName = WeaponHitSoundTable.hitSoundNames(for: weaponType).randomElement()
                    ?? JobHitSoundTable.hitSoundNames(forJob: targetObject.job).randomElement()
            } else {
                hitSoundName = JobHitSoundTable.hitSoundNames(forJob: targetObject.job).randomElement()
            }

            if let hitSoundName {
                let delay = Duration.milliseconds(objectAction.sourceSpeed)
                Task { [weak self] in
                    try? await Task.sleep(for: delay)
                    self?.playSound(named: hitSoundName, on: objectAction.targetObjectID)
                }
            }
        }
    }

    private func soundEffectResource(for soundName: String) async -> AudioBufferResource? {
        if let cached = soundEffectResourceCache[soundName] {
            return cached
        }

        if let existingTask = soundEffectLoadTasks[soundName] {
            return await existingTask.value
        }

        let resourceManager = resourceManager
        let loadTask: Task<AudioBufferResource?, Never> = Task {
            let wavPath = ResourcePath(components: ["data", "wav", soundName])
            guard let wavData = try? await resourceManager.contentsOfResource(at: wavPath),
                  let audioBuffer = AVAudioPCMBuffer.load(from: wavData),
                  let resource = try? AudioBufferResource(
                      buffer: audioBuffer,
                      configuration: AudioBufferResource.Configuration(shouldLoop: false)
                  ) else {
                return nil
            }
            return resource
        }

        soundEffectLoadTasks[soundName] = loadTask

        let resource = await loadTask.value

        soundEffectLoadTasks[soundName] = nil

        if let resource {
            soundEffectResourceCache[soundName] = resource
        }

        return resource
    }
}
