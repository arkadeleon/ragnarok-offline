//
//  ObservablePet.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/8.
//

import Combine
import rAthenaCommon
import RODatabase
import ROResources

class ObservablePet: ObservableObject {
    let mode: ServerMode
    let pet: Pet
    let monster: Monster

    @Published var tameItem: Item?
    @Published var eggItem: Item?
    @Published var equipItem: Item?
    @Published var foodItem: Item?

    var fields: [DatabaseRecordField] {
        var fields: [DatabaseRecordField] = []

        fields.append(("Fullness", "\(pet.fullness)"))
        fields.append(("Hungry Delay", "\(pet.hungryDelay)"))
        fields.append(("Hunger Increase", "\(pet.hungerIncrease)"))

        fields.append(("Intimacy Start", "\(pet.intimacyStart)"))
        fields.append(("Intimacy Fed", "\(pet.intimacyFed)"))
        fields.append(("Intimacy Overfed", "\(pet.intimacyOverfed)"))
        fields.append(("Intimacy Hungry", "\(pet.intimacyHungry)"))
        fields.append(("Intimacy OwnerDie", "\(pet.intimacyOwnerDie)"))

        fields.append(("Capture Rate", "\(pet.captureRate)"))
        fields.append(("Special Performance", "\(pet.specialPerformance)"))
        fields.append(("Attack Rate", "\(pet.attackRate)"))
        fields.append(("Retaliate Rate", "\(pet.retaliateRate)"))
        fields.append(("Change Target Rate", "\(pet.changeTargetRate)"))
        fields.append(("Allow Auto Feed", "\(pet.allowAutoFeed)"))

        return fields
    }

    init(mode: ServerMode, pet: Pet, monster: Monster) {
        self.mode = mode
        self.pet = pet
        self.monster = monster
    }

    func fetchPetInfo() async {
        let itemDatabase = ItemDatabase.database(for: mode)

        if let tameItem = pet.tameItem {
            do {
                let item = try await itemDatabase.item(forAegisName: tameItem)
                self.tameItem = item
            } catch {
            }
        }

        do {
            let item = try await itemDatabase.item(forAegisName: pet.eggItem)
            self.eggItem = item
        } catch {
        }

        if let equipItem = pet.equipItem {
            do {
                let item = try await itemDatabase.item(forAegisName: equipItem)
                self.equipItem = item
            } catch {
            }
        }

        if let foodItem = pet.foodItem {
            do {
                let item = try await itemDatabase.item(forAegisName: foodItem)
                self.foodItem = item
            } catch {
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
