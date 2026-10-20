//
//  MonsterDatabaseFilter.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/12/24.
//

import RagnarokConstants

struct MonsterDatabaseFilter: Equatable {
    var minimumLevel: Int?

    var maximumLevel: Int?

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

    var monsterClass: MonsterClass?

    var availableMonsterClasses: [MonsterClass] {
        MonsterClass.allCases
    }

    var isMVPOnly = false

    var isEmpty: Bool {
        minimumLevel == nil &&
        maximumLevel == nil &&
        size == nil &&
        race == nil &&
        element == nil &&
        monsterClass == nil &&
        !isMVPOnly
    }

    func isIncluded(_ monster: MonsterModel) -> Bool {
        if let minimumLevel, monster.level < minimumLevel {
            return false
        }

        if let maximumLevel, monster.level > maximumLevel {
            return false
        }

        if let size, monster.size != size {
            return false
        }

        if let race, monster.race != race {
            return false
        }

        if let element, monster.element != element {
            return false
        }

        if let monsterClass, monster.class != monsterClass {
            return false
        }

        if isMVPOnly, monster.modes?.contains(.mvp) != true {
            return false
        }

        return true
    }

    mutating func toggleSize(_ size: Size) {
        self.size = self.size == size ? nil : size
    }

    mutating func toggleRace(_ race: Race) {
        self.race = self.race == race ? nil : race
    }

    mutating func toggleElement(_ element: Element) {
        self.element = self.element == element ? nil : element
    }

    mutating func toggleMonsterClass(_ monsterClass: MonsterClass) {
        self.monsterClass = self.monsterClass == monsterClass ? nil : monsterClass
    }

    mutating func reset() {
        minimumLevel = nil
        maximumLevel = nil
        size = nil
        race = nil
        element = nil
        monsterClass = nil
        isMVPOnly = false
    }
}
