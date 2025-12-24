//
//  MonsterDatabaseFilter.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/12/24.
//

import Observation
import RagnarokConstants

@Observable
class MonsterDatabaseFilter {
    var searchText = ""

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

    var identifier: String {
        let size = size?.stringValue ?? "all"
        let race = race?.stringValue ?? "all"
        let element = element?.stringValue ?? "all"

        return "\(searchText)+\(size)+\(race)+\(element)"
    }

    var isEmpty: Bool {
        searchText.isEmpty &&
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

        if searchText.isEmpty {
            return true
        } else {
            return monster.displayName.localizedStandardContains(searchText)
        }
    }

    func reset() {
        size = nil
        race = nil
        element = nil
    }
}
