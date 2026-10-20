//
//  MonsterModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/6/19.
//

import CoreGraphics
import Foundation
import Observation
import RagnarokConstants
import RagnarokDatabase
import RagnarokResources
import RagnarokSprite

@Observable
@dynamicMemberLookup
final class MonsterModel {
    private let mode: DatabaseMode
    private let monster: Monster
    private let resourceManager: ResourceManager

    let localizedName: String?

    var animatedImage: AnimatedImage?

    var displayName: String {
        localizedName ?? monster.name
    }

    var attributes: [DatabaseRecordAttribute] {
        var attributes: [DatabaseRecordAttribute] = []

        attributes.append(.init(name: LocalizedStringResource("ID", table: "Database"), value: "#\(monster.id)"))
        attributes.append(.init(name: LocalizedStringResource("Aegis Name", table: "Database"), value: monster.aegisName))
        attributes.append(.init(name: LocalizedStringResource("Name", table: "Database"), value: monster.name))

        attributes.append(.init(name: LocalizedStringResource("Level", table: "Database"), value: monster.level))

        attributes.append(.init(name: LocalizedStringResource("Base Exp", table: "Database"), value: monster.baseExp))
        attributes.append(.init(name: LocalizedStringResource("Job Exp", table: "Database"), value: monster.jobExp))
        attributes.append(.init(name: LocalizedStringResource("MVP Exp", table: "Database"), value: monster.mvpExp))

        attributes.append(.init(name: LocalizedStringResource("Size", table: "Database"), value: monster.size.localizedName))
        attributes.append(.init(name: LocalizedStringResource("Race", table: "Database"), value: monster.race.localizedName))

        let element = String(localized: monster.element.localizedName) + " " + monster.elementLevel.formatted()
        attributes.append(.init(name: LocalizedStringResource("Element", table: "Database"), value: element, valueColor: monster.element.color))

        attributes.append(.init(name: LocalizedStringResource("AI", table: "Database"), value: monster.ai.stringValue))
        attributes.append(.init(name: LocalizedStringResource("Class", table: "Database"), value: monster.class.localizedName))

        return attributes
    }

    var statAttributes: [DatabaseRecordAttribute] {
        var attributes: [DatabaseRecordAttribute] = []

        attributes.append(.init(name: LocalizedStringResource("HP", table: "Database"), value: monster.hp))
        attributes.append(.init(name: LocalizedStringResource("SP", table: "Database"), value: monster.sp))

        if mode == .prerenewal {
            attributes.append(.init(name: LocalizedStringResource("Minimum Attack", table: "Database"), value: monster.attack))
            attributes.append(.init(name: LocalizedStringResource("Maximum Attack", table: "Database"), value: monster.attack2))
        }

        if mode == .renewal {
            attributes.append(.init(name: LocalizedStringResource("Base Attack", table: "Database"), value: monster.attack))
            attributes.append(.init(name: LocalizedStringResource("Base Magic Attack", table: "Database"), value: monster.attack2))
        }

        attributes.append(.init(name: LocalizedStringResource("Defense", table: "Database"), value: monster.defense))
        attributes.append(.init(name: LocalizedStringResource("Magic Defense", table: "Database"), value: monster.magicDefense))

        attributes.append(.init(name: LocalizedStringResource("Resistance", table: "Database"), value: monster.resistance))
        attributes.append(.init(name: LocalizedStringResource("Magic Resistance", table: "Database"), value: monster.magicResistance))

        attributes.append(.init(name: LocalizedStringResource("Str", table: "Database"), value: monster.str))
        attributes.append(.init(name: LocalizedStringResource("Agi", table: "Database"), value: monster.agi))
        attributes.append(.init(name: LocalizedStringResource("Vit", table: "Database"), value: monster.vit))
        attributes.append(.init(name: LocalizedStringResource("Int", table: "Database"), value: monster.int))
        attributes.append(.init(name: LocalizedStringResource("Dex", table: "Database"), value: monster.dex))
        attributes.append(.init(name: LocalizedStringResource("Luk", table: "Database"), value: monster.luk))

        attributes.append(.init(name: LocalizedStringResource("Damage Taken", table: "Database"), value: formatRate(monster.damageTaken, base: 100)))

        return attributes
    }

    var actionAttributes: [DatabaseRecordAttribute] {
        var attributes: [DatabaseRecordAttribute] = []

        attributes.append(.init(name: LocalizedStringResource("Attack Range", table: "Database"), value: formatCells(monster.attackRange)))
        attributes.append(.init(name: LocalizedStringResource("Skill Range", table: "Database"), value: formatCells(monster.skillRange)))
        attributes.append(.init(name: LocalizedStringResource("Chase Range", table: "Database"), value: formatCells(monster.chaseRange)))

        attributes.append(.init(name: LocalizedStringResource("Walk Speed", table: "Database"), value: formatTime(monster.walkSpeed.rawValue, allowedUnits: [.milliseconds])))
        attributes.append(.init(name: LocalizedStringResource("Attack Delay", table: "Database"), value: formatTime(monster.attackDelay, allowedUnits: [.milliseconds])))
        attributes.append(.init(name: LocalizedStringResource("Attack Motion", table: "Database"), value: formatTime(monster.attackMotion, allowedUnits: [.milliseconds])))
        attributes.append(.init(name: LocalizedStringResource("Client Attack Motion", table: "Database"), value: formatTime(monster.clientAttackMotion, allowedUnits: [.milliseconds])))
        attributes.append(.init(name: LocalizedStringResource("Damage Motion", table: "Database"), value: formatTime(monster.damageMotion, allowedUnits: [.milliseconds])))

        return attributes
    }

    var localizedRaceGroups: [String]? {
        monster.raceGroups?
            .sorted(using: KeyPathComparator(\.rawValue))
            .map { String(localized: $0.localizedName) }
    }

    var localizedModes: [String]? {
        monster.modes?
            .sorted(using: KeyPathComparator(\.rawValue))
            .map { String(localized: $0.localizedName) }
    }

    init(mode: DatabaseMode, monster: Monster, localizedName: String?, resourceManager: ResourceManager) {
        self.mode = mode
        self.monster = monster
        self.localizedName = localizedName
        self.resourceManager = resourceManager
    }

    subscript<Value>(dynamicMember keyPath: KeyPath<Monster, Value>) -> Value {
        monster[keyPath: keyPath]
    }

    @MainActor
    func fetchAnimatedImage() async {
        if animatedImage != nil {
            return
        }

        let composedSprite: ComposedSprite
        do {
            let configuration = ComposedSprite.Configuration(jobID: monster.id)
            composedSprite = try await ComposedSprite(configuration: configuration, resourceManager: resourceManager)
        } catch {
            logger.warning("Composed sprite error: \(error)")
            return
        }

        let renderer = SpriteAnimationRenderer()
        let animation = await renderer.render(
            composedSprite: composedSprite,
            actionType: .idle
        )
        animatedImage = AnimatedImage(animation: animation)
    }
}

extension MonsterModel: Equatable {
    static func == (lhs: MonsterModel, rhs: MonsterModel) -> Bool {
        lhs.monster.id == rhs.monster.id
    }
}

extension MonsterModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(monster.id)
    }
}

extension MonsterModel: Identifiable {
    var id: Int {
        monster.id
    }
}
