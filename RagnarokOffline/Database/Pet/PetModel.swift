//
//  PetModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/8.
//

import Foundation
import Observation
import RagnarokDatabase

@Observable
@dynamicMemberLookup
final class PetModel {
    private let mode: DatabaseMode
    private let pet: Pet

    var monster: MonsterModel?
    var tameItem: ItemModel?
    var eggItem: ItemModel?
    var equipItem: ItemModel?
    var foodItem: ItemModel?

    var aegisName: String {
        pet.monster
    }

    var displayName: String {
        monster?.displayName ?? pet.monster
    }

    var attributes: [DatabaseRecordAttribute] {
        var attributes: [DatabaseRecordAttribute] = []

        attributes.append(.init(name: LocalizedStringResource("Fullness", table: "Database"), value: pet.fullness))
        attributes.append(.init(name: LocalizedStringResource("Hungry Delay", table: "Database"), value: pet.hungryDelay))
        attributes.append(.init(name: LocalizedStringResource("Hunger Increase", table: "Database"), value: pet.hungerIncrease))

        attributes.append(.init(name: LocalizedStringResource("Intimacy Start", table: "Database"), value: pet.intimacyStart))
        attributes.append(.init(name: LocalizedStringResource("Intimacy Fed", table: "Database"), value: pet.intimacyFed))
        attributes.append(.init(name: LocalizedStringResource("Intimacy Overfed", table: "Database"), value: pet.intimacyOverfed))
        attributes.append(.init(name: LocalizedStringResource("Intimacy Hungry", table: "Database"), value: pet.intimacyHungry))
        attributes.append(.init(name: LocalizedStringResource("Intimacy OwnerDie", table: "Database"), value: pet.intimacyOwnerDie))

        attributes.append(.init(name: LocalizedStringResource("Capture Rate", table: "Database"), value: pet.captureRate))
        attributes.append(.init(name: LocalizedStringResource("Special Performance", table: "Database"), value: pet.specialPerformance))
        attributes.append(.init(name: LocalizedStringResource("Attack Rate", table: "Database"), value: pet.attackRate))
        attributes.append(.init(name: LocalizedStringResource("Retaliate Rate", table: "Database"), value: pet.retaliateRate))
        attributes.append(.init(name: LocalizedStringResource("Change Target Rate", table: "Database"), value: pet.changeTargetRate))
        attributes.append(.init(name: LocalizedStringResource("Allow Auto Feed", table: "Database"), value: pet.allowAutoFeed))

        return attributes
    }

    init(mode: DatabaseMode, pet: Pet) {
        self.mode = mode
        self.pet = pet
    }

    subscript<Value>(dynamicMember keyPath: KeyPath<Pet, Value>) -> Value {
        pet[keyPath: keyPath]
    }

    @MainActor
    func fetchDetail(database: DatabaseModel) async {
        if let tameItem = pet.tameItem {
            self.tameItem = await database.item(forAegisName: tameItem)
        }

        eggItem = await database.item(forAegisName: pet.eggItem)

        if let equipItem = pet.equipItem {
            self.equipItem = await database.item(forAegisName: equipItem)
        }

        if let foodItem = pet.foodItem {
            self.foodItem = await database.item(forAegisName: foodItem)
        }
    }
}

extension PetModel: Equatable {
    static func == (lhs: PetModel, rhs: PetModel) -> Bool {
        lhs.pet.monster == rhs.pet.monster
    }
}

extension PetModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(pet.monster)
    }
}

extension PetModel: Identifiable {
    var id: String {
        pet.monster
    }
}
