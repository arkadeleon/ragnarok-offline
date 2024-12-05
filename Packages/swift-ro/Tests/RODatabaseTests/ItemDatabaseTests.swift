//
//  ItemDatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/9.
//

import XCTest
import ROGenerated
@testable import RODatabase

final class ItemDatabaseTests: XCTestCase {
    func testItemType() {
        let weapon = ItemType(rawValue: 5)
        XCTAssertEqual(weapon, ItemType.weapon)

        let armor = ItemType(stringValue: "Armor")
        XCTAssertEqual(armor, ItemType.armor)
    }

    func testPrerenewal() async throws {
        let database = ItemDatabase.prerenewal

        let redPotion = try await database.item(forAegisName: "Red_Potion")!
        XCTAssertEqual(redPotion.id, 501)
        XCTAssertEqual(redPotion.aegisName, "Red_Potion")
        XCTAssertEqual(redPotion.name, "Red Potion")
        XCTAssertEqual(redPotion.type, .healing)
        XCTAssertEqual(redPotion.buy, 50)
        XCTAssertEqual(redPotion.weight, 70)
        XCTAssertEqual(redPotion.script, "itemheal rand(45,65),0;\n")

        let flyWing = try await database.item(forAegisName: "Wing_Of_Fly")!
        XCTAssertEqual(flyWing.id, 601)
        XCTAssertEqual(flyWing.aegisName, "Wing_Of_Fly")
        XCTAssertEqual(flyWing.name, "Fly Wing")
        XCTAssertEqual(flyWing.type, .delayconsume)
        XCTAssertEqual(flyWing.buy, 60)
        XCTAssertEqual(flyWing.weight, 50)
        XCTAssertEqual(flyWing.flags?.buyingStore, true)
        XCTAssertEqual(flyWing.script, "itemskill \"AL_TELEPORT\",1;\n")

        let deadBranch = try await database.item(forAegisName: "Branch_Of_Dead_Tree")!
        XCTAssertEqual(deadBranch.id, 604)
        XCTAssertEqual(deadBranch.aegisName, "Branch_Of_Dead_Tree")
        XCTAssertEqual(deadBranch.name, "Dead Branch")
        XCTAssertEqual(deadBranch.type, .usable)
        XCTAssertEqual(deadBranch.buy, 50)
        XCTAssertEqual(deadBranch.weight, 50)
        XCTAssertEqual(deadBranch.flags?.buyingStore, true)
        XCTAssertEqual(deadBranch.flags?.deadBranch, true)
        XCTAssertEqual(deadBranch.script, "monster \"this\",-1,-1,\"--ja--\",-1-MOBG_BRANCH_OF_DEAD_TREE,1,\"\";\n")

        let sword = try await database.item(forAegisName: "Sword")!
        XCTAssertEqual(sword.id, 1101)
        XCTAssertEqual(sword.aegisName, "Sword")
        XCTAssertEqual(sword.name, "Sword")
        XCTAssertEqual(sword.type, .weapon)
        XCTAssertEqual(sword.subType, .weapon(.w_1hsword))
        XCTAssertEqual(sword.buy, 100)
        XCTAssertEqual(sword.weight, 500)
        XCTAssertEqual(sword.attack, 25)
        XCTAssertEqual(sword.range, 1)
        XCTAssertEqual(sword.slots, 3)
        XCTAssertEqual(sword.jobs, [.alchemist, .assassin, .blacksmith, .crusader, .knight, .merchant, .novice, .rogue, .super_novice, .swordman, .thief])
        XCTAssertEqual(sword.locations, .right_hand)
        XCTAssertEqual(sword.weaponLevel, 1)
        XCTAssertEqual(sword.equipLevelMin, 2)
        XCTAssertEqual(sword.refineable, true)

        let eraser = try await database.item(forAegisName: "Eraser")!
        XCTAssertEqual(eraser.id, 1637)
        XCTAssertEqual(eraser.aegisName, "Eraser")
        XCTAssertEqual(eraser.name, "Eraser")
        XCTAssertEqual(eraser.type, .weapon)
        XCTAssertEqual(eraser.subType, .weapon(.w_staff))
        XCTAssertEqual(eraser.buy, 20)
        XCTAssertEqual(eraser.weight, 500)
        XCTAssertEqual(eraser.attack, 80)
        XCTAssertEqual(eraser.range, 1)
        XCTAssertEqual(eraser.jobs, [.acolyte, .mage, .monk, .priest, .sage, .wizard])
        XCTAssertEqual(eraser.classes, .upper)
        XCTAssertEqual(eraser.locations, .right_hand)
        XCTAssertEqual(eraser.weaponLevel, 4)
        XCTAssertEqual(eraser.equipLevelMin, 70)
        XCTAssertEqual(eraser.refineable, true)

        let sheild = try await database.item(forAegisName: "Shield")!
        XCTAssertEqual(sheild.id, 2105)
        XCTAssertEqual(sheild.aegisName, "Shield")
        XCTAssertEqual(sheild.name, "Shield")
        XCTAssertEqual(sheild.type, .armor)
        XCTAssertEqual(sheild.buy, 56000)
        XCTAssertEqual(sheild.weight, 1300)
        XCTAssertEqual(sheild.defense, 6)
        XCTAssertEqual(sheild.jobs, [.crusader, .knight, .swordman])
        XCTAssertEqual(sheild.locations, .left_hand)
        XCTAssertEqual(sheild.armorLevel, 1)
        XCTAssertEqual(sheild.refineable, true)

        let turban = try await database.item(forAegisName: "Turban")!
        XCTAssertEqual(turban.id, 2222)
        XCTAssertEqual(turban.aegisName, "Turban")
        XCTAssertEqual(turban.name, "Turban")
        XCTAssertEqual(turban.type, .armor)
        XCTAssertEqual(turban.buy, 4500)
        XCTAssertEqual(turban.weight, 300)
        XCTAssertEqual(turban.defense, 3)
        XCTAssertEqual(turban.jobs, [.acolyte, .alchemist, .archer, .assassin, .barddancer, .blacksmith, .crusader, .gunslinger, .hunter, .kagerouoboro, .knight, .mage, .merchant, .monk, .ninja, .priest, .rebellion, .rogue, .sage, .soul_linker, .star_gladiator, .summoner, .swordman, .taekwon, .thief, .wizard])
        XCTAssertEqual(turban.locations, .head_top)
        XCTAssertEqual(turban.armorLevel, 1)
        XCTAssertEqual(turban.refineable, true)
        XCTAssertEqual(turban.view, 7)

        let poringCard = try await database.item(forAegisName: "Poring_Card")!
        XCTAssertEqual(poringCard.id, 4001)
        XCTAssertEqual(poringCard.aegisName, "Poring_Card")
        XCTAssertEqual(poringCard.name, "Poring Card")
        XCTAssertEqual(poringCard.type, .card)
        XCTAssertEqual(poringCard.buy, 20)
        XCTAssertEqual(poringCard.weight, 10)
        XCTAssertEqual(poringCard.locations, [.armor])
        XCTAssertEqual(poringCard.flags?.buyingStore, true)
        XCTAssertEqual(poringCard.script, "bonus bLuk,2;\nbonus bFlee2,1;\n")
    }

    func testRenewal() async throws {
        let database = ItemDatabase.renewal

        let redPotion = try await database.item(forAegisName: "Red_Potion")!
        XCTAssertEqual(redPotion.id, 501)
        XCTAssertEqual(redPotion.aegisName, "Red_Potion")
        XCTAssertEqual(redPotion.name, "Red Potion")
        XCTAssertEqual(redPotion.type, .healing)
        XCTAssertEqual(redPotion.buy, 10)
        XCTAssertEqual(redPotion.weight, 70)
        XCTAssertEqual(redPotion.script, "itemheal rand(45,65),0;\n")

        let flyWing = try await database.item(forAegisName: "Wing_Of_Fly")!
        XCTAssertEqual(flyWing.id, 601)
        XCTAssertEqual(flyWing.aegisName, "Wing_Of_Fly")
        XCTAssertEqual(flyWing.name, "Fly Wing")
        XCTAssertEqual(flyWing.type, .delayconsume)
        XCTAssertEqual(flyWing.buy, 250)
        XCTAssertEqual(flyWing.weight, 50)
        XCTAssertEqual(flyWing.flags?.buyingStore, true)
        XCTAssertEqual(flyWing.script, "itemskill \"AL_TELEPORT\",1;\n")

        let deadBranch = try await database.item(forAegisName: "Branch_Of_Dead_Tree")!
        XCTAssertEqual(deadBranch.id, 604)
        XCTAssertEqual(deadBranch.aegisName, "Branch_Of_Dead_Tree")
        XCTAssertEqual(deadBranch.name, "Dead Branch")
        XCTAssertEqual(deadBranch.type, .usable)
        XCTAssertEqual(deadBranch.buy, 50)
        XCTAssertEqual(deadBranch.weight, 50)
        XCTAssertEqual(deadBranch.flags?.buyingStore, true)
        XCTAssertEqual(deadBranch.flags?.deadBranch, true)
        XCTAssertEqual(deadBranch.script, "monster \"this\",-1,-1,\"--ja--\",-1-MOBG_BRANCH_OF_DEAD_TREE,1,\"\";\n")

        let sword = try await database.item(forAegisName: "Sword")!
        XCTAssertEqual(sword.id, 1101)
        XCTAssertEqual(sword.aegisName, "Sword")
        XCTAssertEqual(sword.name, "Sword")
        XCTAssertEqual(sword.type, .weapon)
        XCTAssertEqual(sword.subType, .weapon(.w_1hsword))
        XCTAssertEqual(sword.buy, 100)
        XCTAssertEqual(sword.weight, 500)
        XCTAssertEqual(sword.attack, 25)
        XCTAssertEqual(sword.range, 1)
        XCTAssertEqual(sword.slots, 3)
        XCTAssertEqual(sword.jobs, [.alchemist, .assassin, .blacksmith, .crusader, .knight, .merchant, .novice, .rogue, .super_novice, .swordman, .thief])
        XCTAssertEqual(sword.locations, .right_hand)
        XCTAssertEqual(sword.weaponLevel, 1)
        XCTAssertEqual(sword.equipLevelMin, 2)
        XCTAssertEqual(sword.refineable, true)

        let eraser = try await database.item(forAegisName: "Eraser")!
        XCTAssertEqual(eraser.id, 1637)
        XCTAssertEqual(eraser.aegisName, "Eraser")
        XCTAssertEqual(eraser.name, "Eraser")
        XCTAssertEqual(eraser.type, .weapon)
        XCTAssertEqual(eraser.subType, .weapon(.w_staff))
        XCTAssertEqual(eraser.buy, 20)
        XCTAssertEqual(eraser.weight, 500)
        XCTAssertEqual(eraser.attack, 80)
        XCTAssertEqual(eraser.magicAttack, 170)
        XCTAssertEqual(eraser.range, 1)
        XCTAssertEqual(eraser.jobs, [.acolyte, .mage, .monk, .priest, .sage, .wizard])
        XCTAssertEqual(eraser.classes, .all_upper)
        XCTAssertEqual(eraser.locations, .right_hand)
        XCTAssertEqual(eraser.weaponLevel, 4)
        XCTAssertEqual(eraser.equipLevelMin, 70)
        XCTAssertEqual(eraser.refineable, true)

        let sheild = try await database.item(forAegisName: "Shield")!
        XCTAssertEqual(sheild.id, 2105)
        XCTAssertEqual(sheild.aegisName, "Shield")
        XCTAssertEqual(sheild.name, "Shield")
        XCTAssertEqual(sheild.type, .armor)
        XCTAssertEqual(sheild.buy, 56000)
        XCTAssertEqual(sheild.weight, 1300)
        XCTAssertEqual(sheild.defense, 60)
        XCTAssertEqual(sheild.jobs, [.crusader, .knight, .swordman])
        XCTAssertEqual(sheild.locations, .left_hand)
        XCTAssertEqual(sheild.armorLevel, 1)
        XCTAssertEqual(sheild.refineable, true)

        let turban = try await database.item(forAegisName: "Turban")!
        XCTAssertEqual(turban.id, 2222)
        XCTAssertEqual(turban.aegisName, "Turban")
        XCTAssertEqual(turban.name, "Turban")
        XCTAssertEqual(turban.type, .armor)
        XCTAssertEqual(turban.buy, 4500)
        XCTAssertEqual(turban.weight, 300)
        XCTAssertEqual(turban.defense, 5)
        XCTAssertEqual(turban.jobs, [.acolyte, .alchemist, .archer, .assassin, .barddancer, .blacksmith, .crusader, .gunslinger, .hunter, .kagerouoboro, .knight, .mage, .merchant, .monk, .ninja, .priest, .rebellion, .rogue, .sage, .soul_linker, .star_gladiator, .summoner, .swordman, .taekwon, .thief, .wizard])
        XCTAssertEqual(turban.locations, .head_top)
        XCTAssertEqual(turban.armorLevel, 1)
        XCTAssertEqual(turban.refineable, true)
        XCTAssertEqual(turban.view, 7)

        let poringCard = try await database.item(forAegisName: "Poring_Card")!
        XCTAssertEqual(poringCard.id, 4001)
        XCTAssertEqual(poringCard.aegisName, "Poring_Card")
        XCTAssertEqual(poringCard.name, "Poring Card")
        XCTAssertEqual(poringCard.type, .card)
        XCTAssertEqual(poringCard.buy, 20)
        XCTAssertEqual(poringCard.weight, 10)
        XCTAssertEqual(poringCard.locations, [.armor])
        XCTAssertEqual(poringCard.flags?.buyingStore, true)
        XCTAssertEqual(poringCard.flags?.dropEffect, "CLIENT")
        XCTAssertEqual(poringCard.script, "bonus bLuk,2;\nbonus bFlee2,1;\n")
    }
}
