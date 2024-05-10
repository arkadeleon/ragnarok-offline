//
//  DatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/1/9.
//

import XCTest
import rAthenaResource
@testable import RODatabase

final class DatabaseTests: XCTestCase {
    let database = Database.renewal

    override func setUp() async throws {
        try await ResourceBundle.shared.load()
    }

    func testJobDatabase() async throws {
        let jobs = try await database.jobs()
    }

    func testSkillDatabase() async throws {
        let skills = try await database.skills()

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

    func testMapDatabase() async throws {
        let maps = try await database.maps()
        XCTAssertEqual(maps.count, 1219)
    }

    func testMonsterSpawnDatabase() async throws {
        let poring = try await MonsterDatabase.renewal.monster(forAegisName: "PORING")
        let poringMonsterSpawns = try await database.monsterSpawns(forMonster: poring)
        XCTAssertEqual(poringMonsterSpawns.count, 15)

        let prtfild08 = try await database.map(forName: "prt_fild08")
        let prtfild08MonsterSpawns = try await database.monsterSpawns(forMap: prtfild08)
        XCTAssertEqual(prtfild08MonsterSpawns.count, 6)
    }
}
