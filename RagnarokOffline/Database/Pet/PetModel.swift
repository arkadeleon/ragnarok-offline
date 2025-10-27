//
//  PetModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/8.
//

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

        attributes.append(.init(name: "Fullness", value: pet.fullness))
        attributes.append(.init(name: "Hungry Delay", value: pet.hungryDelay))
        attributes.append(.init(name: "Hunger Increase", value: pet.hungerIncrease))

        attributes.append(.init(name: "Intimacy Start", value: pet.intimacyStart))
        attributes.append(.init(name: "Intimacy Fed", value: pet.intimacyFed))
        attributes.append(.init(name: "Intimacy Overfed", value: pet.intimacyOverfed))
        attributes.append(.init(name: "Intimacy Hungry", value: pet.intimacyHungry))
        attributes.append(.init(name: "Intimacy OwnerDie", value: pet.intimacyOwnerDie))

        attributes.append(.init(name: "Capture Rate", value: pet.captureRate))
        attributes.append(.init(name: "Special Performance", value: pet.specialPerformance))
        attributes.append(.init(name: "Attack Rate", value: pet.attackRate))
        attributes.append(.init(name: "Retaliate Rate", value: pet.retaliateRate))
        attributes.append(.init(name: "Change Target Rate", value: pet.changeTargetRate))
        attributes.append(.init(name: "Allow Auto Feed", value: pet.allowAutoFeed))

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
