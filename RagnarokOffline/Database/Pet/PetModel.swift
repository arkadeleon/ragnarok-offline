//
//  PetModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/8.
//

import Observation
import RODatabase

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
    func fetchMonster() async {
        if monster == nil {
            let monsterDatabase = MonsterDatabase.shared
            if let monster = await monsterDatabase.monster(forAegisName: pet.monster) {
                self.monster = MonsterModel(mode: mode, monster: monster)
            }
        }
    }

    @MainActor
    func fetchDetail() async {
        let itemDatabase = ItemDatabase.shared

        if let tameItem = pet.tameItem {
            if let item = await itemDatabase.item(forAegisName: tameItem) {
                self.tameItem = await ItemModel(mode: mode, item: item)
            }
        }

        if let item = await itemDatabase.item(forAegisName: pet.eggItem) {
            self.eggItem = await ItemModel(mode: mode, item: item)
        }

        if let equipItem = pet.equipItem {
            if let item = await itemDatabase.item(forAegisName: equipItem) {
                self.equipItem = await ItemModel(mode: mode, item: item)
            }
        }

        if let foodItem = pet.foodItem {
            if let item = await itemDatabase.item(forAegisName: foodItem) {
                self.foodItem = await ItemModel(mode: mode, item: item)
            }
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
