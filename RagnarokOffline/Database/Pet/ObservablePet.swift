//
//  ObservablePet.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/8.
//

import Observation
import rAthenaCommon
import RODatabase

@Observable class ObservablePet {
    let mode: ServerMode
    let pet: Pet
    let monster: Monster

    var tameItem: Item?
    var eggItem: Item?
    var equipItem: Item?
    var foodItem: Item?

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

    init(mode: ServerMode, pet: Pet, monster: Monster) {
        self.mode = mode
        self.pet = pet
        self.monster = monster
    }

    func fetchPetInfo() async {
        let itemDatabase = ItemDatabase.database(for: mode)

        if let tameItem = pet.tameItem {
            if let item = try? await itemDatabase.item(forAegisName: tameItem) {
                self.tameItem = item
            }
        }

        if let item = try? await itemDatabase.item(forAegisName: pet.eggItem) {
            self.eggItem = item
        }

        if let equipItem = pet.equipItem {
            if let item = try? await itemDatabase.item(forAegisName: equipItem) {
                self.equipItem = item
            }
        }

        if let foodItem = pet.foodItem {
            if let item = try? await itemDatabase.item(forAegisName: foodItem) {
                self.foodItem = item
            }
        }
    }
}

extension ObservablePet: Equatable {
    static func == (lhs: ObservablePet, rhs: ObservablePet) -> Bool {
        lhs.pet.monster == rhs.pet.monster
    }
}

extension ObservablePet: Identifiable {
    var id: String {
        pet.monster
    }
}

extension ObservablePet: Hashable {
    func hash(into hasher: inout Hasher) {
        pet.monster.hash(into: &hasher)
    }
}
