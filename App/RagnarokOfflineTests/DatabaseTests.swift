//
//  DatabaseTests.swift
//  rAthenaTests
//
//  Created by Leon Li on 2024/1/9.
//

import XCTest
@testable import rAthenaResource
@testable import rAthenaDatabase

final class DatabaseTests: XCTestCase {
    let database = Database.renewal

    override func setUp() async throws {
        try await ResourceBundle.shared.load()
    }

    func testItemDatabase() async throws {
        let items = try await database.items()
        XCTAssertEqual(items.count, 25896)

        let redPotion = try await database.item(forAegisName: "Red_Potion")
        XCTAssertEqual(redPotion.id, 501)
        XCTAssertEqual(redPotion.aegisName, "Red_Potion")
        XCTAssertEqual(redPotion.name, "Red Potion")
        XCTAssertEqual(redPotion.type, .healing)
        XCTAssertEqual(redPotion.buy, 10)
        XCTAssertEqual(redPotion.weight, 70)
        XCTAssertEqual(redPotion.script, "itemheal rand(45,65),0;\n")

        let flyWing = try await database.item(forAegisName: "Wing_Of_Fly")
        XCTAssertEqual(flyWing.id, 601)
        XCTAssertEqual(flyWing.aegisName, "Wing_Of_Fly")
        XCTAssertEqual(flyWing.name, "Fly Wing")
        XCTAssertEqual(flyWing.type, .delayConsume)
        XCTAssertEqual(flyWing.buy, 250)
        XCTAssertEqual(flyWing.weight, 50)
        XCTAssertEqual(flyWing.flags?.buyingStore, true)
        XCTAssertEqual(flyWing.script, "itemskill \"AL_TELEPORT\",1;\n")

        let deadBranch = try await database.item(forAegisName: "Branch_Of_Dead_Tree")
        XCTAssertEqual(deadBranch.id, 604)
        XCTAssertEqual(deadBranch.aegisName, "Branch_Of_Dead_Tree")
        XCTAssertEqual(deadBranch.name, "Dead Branch")
        XCTAssertEqual(deadBranch.type, .usable)
        XCTAssertEqual(deadBranch.buy, 50)
        XCTAssertEqual(deadBranch.weight, 50)
        XCTAssertEqual(deadBranch.flags?.buyingStore, true)
        XCTAssertEqual(deadBranch.flags?.deadBranch, true)
        XCTAssertEqual(deadBranch.script, "monster \"this\",-1,-1,\"--ja--\",-1-MOBG_BRANCH_OF_DEAD_TREE,1,\"\";\n")

        let sword = try await database.item(forAegisName: "Sword")
        XCTAssertEqual(sword.id, 1101)
        XCTAssertEqual(sword.aegisName, "Sword")
        XCTAssertEqual(sword.name, "Sword")
        XCTAssertEqual(sword.type, .weapon)
        XCTAssertEqual(sword.subType, .weapon(.oneHandedSword))
        XCTAssertEqual(sword.buy, 100)
        XCTAssertEqual(sword.weight, 500)
        XCTAssertEqual(sword.attack, 25)
        XCTAssertEqual(sword.range, 1)
        XCTAssertEqual(sword.slots, 3)
//        XCTAssertEqual(sword.jobs[0] as! UInt, UInt(1 << RA_MAPID_NOVICE) | UInt(1 << RA_MAPID_SWORDMAN) | UInt(1 << RA_MAPID_MERCHANT) | UInt(1 << RA_MAPID_THIEF))
//        XCTAssertEqual(sword.jobs[1] as! UInt, UInt(1 << (RA_MAPID_SUPER_NOVICE & RA_MAPID_BASEMASK)) | UInt(1 << (RA_MAPID_KNIGHT & RA_MAPID_BASEMASK)) | UInt(1 << (RA_MAPID_BLACKSMITH & RA_MAPID_BASEMASK)) | UInt(1 << (RA_MAPID_ASSASSIN & RA_MAPID_BASEMASK)))
//        XCTAssertEqual(sword.jobs[2] as! UInt, UInt(1 << (RA_MAPID_CRUSADER & RA_MAPID_BASEMASK)) | UInt(1 << (RA_MAPID_ALCHEMIST & RA_MAPID_BASEMASK)) | UInt(1 << (RA_MAPID_ROGUE & RA_MAPID_BASEMASK)))
        XCTAssertEqual(sword.locations, [.rightHand])
        XCTAssertEqual(sword.weaponLevel, 1)
        XCTAssertEqual(sword.equipLevelMin, 2)
        XCTAssertEqual(sword.refineable, true)

        let eraser = try await database.item(forAegisName: "Eraser")
        XCTAssertEqual(eraser.id, 1637)
        XCTAssertEqual(eraser.aegisName, "Eraser")
        XCTAssertEqual(eraser.name, "Eraser")
        XCTAssertEqual(eraser.type, .weapon)
        XCTAssertEqual(eraser.subType, .weapon(.staff))
        XCTAssertEqual(eraser.buy, 20)
        XCTAssertEqual(eraser.weight, 500)
        XCTAssertEqual(eraser.attack, 80)
        XCTAssertEqual(eraser.magicAttack, 170)
        XCTAssertEqual(eraser.range, 1)
        XCTAssertEqual(eraser.jobs, [.acolyte, .mage, .monk, .priest, .sage, .wizard])
        XCTAssertEqual(eraser.classes, [.allUpper])
        XCTAssertEqual(eraser.locations, [.rightHand])
        XCTAssertEqual(eraser.weaponLevel, 4)
        XCTAssertEqual(eraser.equipLevelMin, 70)
        XCTAssertEqual(eraser.refineable, true)

        let sheild = try await database.item(forAegisName: "Shield")
        XCTAssertEqual(sheild.id, 2105)
        XCTAssertEqual(sheild.aegisName, "Shield")
        XCTAssertEqual(sheild.name, "Shield")
        XCTAssertEqual(sheild.type, .armor)
        XCTAssertEqual(sheild.buy, 56000)
        XCTAssertEqual(sheild.weight, 1300)
        XCTAssertEqual(sheild.defense, 60)
        XCTAssertEqual(sheild.jobs, [.crusader, .knight, .swordman])
        XCTAssertEqual(sheild.locations, [.leftHand])
        XCTAssertEqual(sheild.armorLevel, 1)
        XCTAssertEqual(sheild.refineable, true)

        let turban = try await database.item(forAegisName: "Turban")
        XCTAssertEqual(turban.id, 2222)
        XCTAssertEqual(turban.aegisName, "Turban")
        XCTAssertEqual(turban.name, "Turban")
        XCTAssertEqual(turban.type, .armor)
        XCTAssertEqual(turban.buy, 4500)
        XCTAssertEqual(turban.weight, 300)
        XCTAssertEqual(turban.defense, 5)
//        XCTAssertEqual(turban.jobs[0] as! UInt, UInt.max & ~UInt(1 << RA_MAPID_NOVICE))
//        XCTAssertEqual(turban.jobs[1] as! UInt, UInt.max & ~UInt(1 << (RA_MAPID_SUPER_NOVICE & RA_MAPID_BASEMASK)))
//        XCTAssertEqual(turban.jobs[2] as! UInt, UInt.max)
        XCTAssertEqual(turban.locations, [.headTop])
        XCTAssertEqual(turban.armorLevel, 1)
        XCTAssertEqual(turban.refineable, true)
        XCTAssertEqual(turban.view, 7)

        let poringCard = try await database.item(forAegisName: "Poring_Card")
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

    func testMonsterDatabase() async throws {
        let monsters = try await database.monsters()
        XCTAssertEqual(monsters.count, 2445)

        let poring = try await database.monster(forAegisName: "PORING")
        XCTAssertEqual(poring.aegisName, "PORING")
        XCTAssertEqual(poring.name, "Poring")
        XCTAssertEqual(poring.level, 1)
        XCTAssertEqual(poring.hp, 60)
        XCTAssertEqual(poring.baseExp, 150)
        XCTAssertEqual(poring.jobExp, 40)
        XCTAssertEqual(poring.attack, 8)
        XCTAssertEqual(poring.attack2, 1)
        XCTAssertEqual(poring.defense, 2)
        XCTAssertEqual(poring.magicDefense, 5)
        XCTAssertEqual(poring.str, 6)
        XCTAssertEqual(poring.agi, 1)
        XCTAssertEqual(poring.vit, 1)
        XCTAssertEqual(poring.int, 1)
        XCTAssertEqual(poring.dex, 6)
        XCTAssertEqual(poring.luk, 5)
        XCTAssertEqual(poring.attackRange, 1)
        XCTAssertEqual(poring.skillRange, 10)
        XCTAssertEqual(poring.chaseRange, 12)
        XCTAssertEqual(poring.size, .medium)
        XCTAssertEqual(poring.race, .plant)
        XCTAssertEqual(poring.element, .water)
        XCTAssertEqual(poring.elementLevel, 1)
        XCTAssertEqual(poring.walkSpeed.rawValue, 400)
        XCTAssertEqual(poring.attackDelay, 1872)
        XCTAssertEqual(poring.attackMotion, 672)
        XCTAssertEqual(poring.damageMotion, 480)
        XCTAssertEqual(poring.ai, .ai02)
        XCTAssertEqual(poring.class, .normal)
        XCTAssertEqual(poring.drops?.count, 8)

        let archerSkeleton = try await database.monster(forAegisName: "ARCHER_SKELETON")
        XCTAssertEqual(archerSkeleton.aegisName, "ARCHER_SKELETON")
        XCTAssertEqual(archerSkeleton.name, "Archer Skeleton")
        XCTAssertEqual(archerSkeleton.level, 50)
        XCTAssertEqual(archerSkeleton.hp, 1646)
        XCTAssertEqual(archerSkeleton.baseExp, 436)
        XCTAssertEqual(archerSkeleton.jobExp, 327)
        XCTAssertEqual(archerSkeleton.attack, 95)
        XCTAssertEqual(archerSkeleton.attack2, 23)
        XCTAssertEqual(archerSkeleton.defense, 47)
        XCTAssertEqual(archerSkeleton.magicDefense, 10)
        XCTAssertEqual(archerSkeleton.str, 30)
        XCTAssertEqual(archerSkeleton.agi, 29)
        XCTAssertEqual(archerSkeleton.vit, 20)
        XCTAssertEqual(archerSkeleton.int, 10)
        XCTAssertEqual(archerSkeleton.dex, 35)
        XCTAssertEqual(archerSkeleton.luk, 5)
        XCTAssertEqual(archerSkeleton.attackRange, 9)
        XCTAssertEqual(archerSkeleton.skillRange, 10)
        XCTAssertEqual(archerSkeleton.chaseRange, 12)
        XCTAssertEqual(archerSkeleton.size, .medium)
        XCTAssertEqual(archerSkeleton.race, .undead)
        XCTAssertEqual(archerSkeleton.raceGroups, [.clocktower])
        XCTAssertEqual(archerSkeleton.element, .undead)
        XCTAssertEqual(archerSkeleton.elementLevel, 1)
        XCTAssertEqual(archerSkeleton.walkSpeed.rawValue, 300)
        XCTAssertEqual(archerSkeleton.attackDelay, 2864)
        XCTAssertEqual(archerSkeleton.attackMotion, 864)
        XCTAssertEqual(archerSkeleton.damageMotion, 576)
        XCTAssertEqual(archerSkeleton.ai, .ai05)
        XCTAssertEqual(archerSkeleton.class, .normal)
        XCTAssertEqual(archerSkeleton.drops?.count, 8)

        let osiris = try await database.monster(forAegisName: "OSIRIS")
        XCTAssertEqual(osiris.ai, .ai21)
        XCTAssertEqual(osiris.class, .boss)
        XCTAssertEqual(osiris.modes, [.mvp])
        XCTAssertEqual(osiris.mvpDrops?.count, 3)
    }

    func testJobDatabase() async throws {
        let jobs = try await database.jobs()
        XCTAssertEqual(jobs.count, 170)
    }

    func testSkillDatabase() async throws {
        let skills = try await database.skills()
        XCTAssertEqual(skills.count, 1533)

        let napalmBeat = try await database.skill(forAegisName: "MG_NAPALMBEAT")
        XCTAssertEqual(napalmBeat.id, 11)
        XCTAssertEqual(napalmBeat.aegisName, "MG_NAPALMBEAT")
        XCTAssertEqual(napalmBeat.name, "Napalm Beat")
        XCTAssertEqual(napalmBeat.maxLevel, 10)
        XCTAssertEqual(napalmBeat.type, .magic)
        XCTAssertEqual(napalmBeat.targetType, .attack)
        XCTAssertEqual(napalmBeat.damageFlags, [.splash, .splashSplit])
        XCTAssertEqual(napalmBeat.flags, [.isAutoShadowSpell, .targetTrap])
        XCTAssertEqual(napalmBeat.range, .left(9))

        let spearBoomerang = try await database.skill(forAegisName: "KN_SPEARBOOMERANG")
        XCTAssertEqual(spearBoomerang.id, 59)
        XCTAssertEqual(spearBoomerang.aegisName, "KN_SPEARBOOMERANG")
        XCTAssertEqual(spearBoomerang.name, "Spear Boomerang")
        XCTAssertEqual(spearBoomerang.maxLevel, 5)
        XCTAssertEqual(spearBoomerang.type, .weapon)
        XCTAssertEqual(spearBoomerang.targetType, .attack)
        XCTAssertEqual(spearBoomerang.range, .right([3, 5, 7, 9, 11]))

        let sightrasher = try await database.skill(forAegisName: "WZ_SIGHTRASHER")
        XCTAssertEqual(sightrasher.id, 81)
        XCTAssertEqual(sightrasher.requires?.status, ["Sight"])
    }

    func testSkillTreeDatabase() async throws {
        let skillTrees = try await database.skillTrees()
        XCTAssertEqual(skillTrees.count, 169)

        let acolyte = try await database.skillTree(forJobID: Job.acolyte.id)
        XCTAssertEqual(acolyte.job, .acolyte)
        XCTAssertEqual(acolyte.inherit, [.novice])
        XCTAssertEqual(acolyte.tree?.count, 15)

        let archBishop = try await database.skillTree(forJobID: Job.archBishop.id)
        XCTAssertEqual(archBishop.job, .archBishop)
        XCTAssertEqual(archBishop.inherit, [.novice, .acolyte, .priest])
        XCTAssertEqual(archBishop.tree?.count, 22)
    }

    func testMapDatabase() async throws {
        let maps = try await database.maps()
        XCTAssertEqual(maps.count, 1219)
    }

    func testMonsterSpawnDatabase() async throws {
        let poring = try await database.monster(forAegisName: "PORING")
        let poringMonsterSpawns = try await database.monsterSpawns(forMonster: poring)
        XCTAssertEqual(poringMonsterSpawns.count, 15)

        let prtfild08 = try await database.map(forName: "prt_fild08")
        let prtfild08MonsterSpawns = try await database.monsterSpawns(forMap: prtfild08)
        XCTAssertEqual(prtfild08MonsterSpawns.count, 6)
    }

    static var allTests = [
        ("testItemDatabase", testItemDatabase),
        ("testMonsterDatabase", testMonsterDatabase),
        ("testJobDatabase", testJobDatabase),
        ("testSkillDatabase", testSkillDatabase),
        ("testSkillTreeDatabase", testSkillTreeDatabase),
        ("testMapDatabase", testMapDatabase),
        ("testMonsterSpawnDatabase", testMonsterSpawnDatabase),
    ]
}
