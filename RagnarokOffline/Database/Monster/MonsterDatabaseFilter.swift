//
//  MonsterDatabaseFilter.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/12/24.
//

import RagnarokConstants

struct MonsterDatabaseFilter: Equatable {
    var size: Size?

    var availableSizes: [Size] {
        [.small, .medium, .large]
    }

    var race: Race?

    var availableRaces: [Race] {
        Race.allCases
    }

    var element: Element?

    var availableElements: [Element] {
        [.neutral, .water, .earth, .fire, .wind, .poison, .holy, .dark, .ghost, .undead]
    }

    var isEmpty: Bool {
        size == nil &&
        race == nil &&
        element == nil
    }

    func isIncluded(_ monster: MonsterModel) -> Bool {
        if let size, monster.size != size {
            return false
        }

        if let race, monster.race != race {
            return false
        }

        if let element, monster.element != element {
            return false
        }

        return true
    }

    mutating func reset() {
        size = nil
        race = nil
        element = nil
    }
}
