//
//  PetModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/8.
//

import Foundation
import RagnarokDatabase

@dynamicMemberLookup
final class PetModel {
    private let pet: Pet

    var attributes: [DatabaseRecordAttribute] {
        var attributes: [DatabaseRecordAttribute] = []

        attributes.append(.init(name: LocalizedStringResource("Fullness", table: "Database"), value: pet.fullness))
        attributes.append(.init(name: LocalizedStringResource("Hungry Delay", table: "Database"), value: formatTime(pet.hungryDelay * 1000)))
        attributes.append(.init(name: LocalizedStringResource("Hunger Increase", table: "Database"), value: pet.hungerIncrease))

        attributes.append(.init(name: LocalizedStringResource("Intimacy Start", table: "Database"), value: pet.intimacyStart))
        attributes.append(.init(name: LocalizedStringResource("Intimacy Fed", table: "Database"), value: pet.intimacyFed))
        attributes.append(.init(name: LocalizedStringResource("Intimacy Overfed", table: "Database"), value: pet.intimacyOverfed))
        attributes.append(.init(name: LocalizedStringResource("Intimacy Hungry", table: "Database"), value: pet.intimacyHungry))
        attributes.append(.init(name: LocalizedStringResource("Intimacy OwnerDie", table: "Database"), value: pet.intimacyOwnerDie))

        attributes.append(.init(name: LocalizedStringResource("Capture Rate", table: "Database"), value: formatRate(pet.captureRate, base: 10000)))
        attributes.append(.init(name: LocalizedStringResource("Special Performance", table: "Database"), value: pet.specialPerformance))
        attributes.append(.init(name: LocalizedStringResource("Attack Rate", table: "Database"), value: formatRate(pet.attackRate, base: 10000)))
        attributes.append(.init(name: LocalizedStringResource("Retaliate Rate", table: "Database"), value: formatRate(pet.retaliateRate, base: 10000)))
        attributes.append(.init(name: LocalizedStringResource("Change Target Rate", table: "Database"), value: formatRate(pet.changeTargetRate, base: 10000)))
        attributes.append(.init(name: LocalizedStringResource("Allow Auto Feed", table: "Database"), value: pet.allowAutoFeed))

        return attributes
    }

    init(pet: Pet) {
        self.pet = pet
    }

    subscript<Value>(dynamicMember keyPath: KeyPath<Pet, Value>) -> Value {
        pet[keyPath: keyPath]
    }

    func usages(ofItemNamed itemAegisName: String) -> [MonsterModel.PetItem.Kind] {
        var usages: [MonsterModel.PetItem.Kind] = []
        if pet.tameItem == itemAegisName {
            usages.append(.tame)
        }
        if pet.eggItem == itemAegisName {
            usages.append(.egg)
        }
        if pet.equipItem == itemAegisName {
            usages.append(.equip)
        }
        if pet.foodItem == itemAegisName {
            usages.append(.food)
        }
        return usages
    }
}
