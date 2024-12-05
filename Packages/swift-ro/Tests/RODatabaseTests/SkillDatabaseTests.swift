//
//  SkillDatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/10.
//

import XCTest
@testable import RODatabase

final class SkillDatabaseTests: XCTestCase {
    func testPrerenewal() async throws {
        let database = SkillDatabase.prerenewal

        let napalmBeat = try await database.skill(forAegisName: "MG_NAPALMBEAT")!
        XCTAssertEqual(napalmBeat.id, 11)
        XCTAssertEqual(napalmBeat.aegisName, "MG_NAPALMBEAT")
        XCTAssertEqual(napalmBeat.name, "Napalm Beat")
        XCTAssertEqual(napalmBeat.maxLevel, 10)
        XCTAssertEqual(napalmBeat.type, .magic)
        XCTAssertEqual(napalmBeat.targetType, .attack)
        XCTAssertEqual(napalmBeat.damageFlags, [.splash, .splashsplit])
        XCTAssertEqual(napalmBeat.flags, [.isautoshadowspell, .targettrap])
        XCTAssertEqual(napalmBeat.range, .left(9))

        let spearBoomerang = try await database.skill(forAegisName: "KN_SPEARBOOMERANG")!
        XCTAssertEqual(spearBoomerang.id, 59)
        XCTAssertEqual(spearBoomerang.aegisName, "KN_SPEARBOOMERANG")
        XCTAssertEqual(spearBoomerang.name, "Spear Boomerang")
        XCTAssertEqual(spearBoomerang.maxLevel, 5)
        XCTAssertEqual(spearBoomerang.type, .weapon)
        XCTAssertEqual(spearBoomerang.targetType, .attack)
        XCTAssertEqual(spearBoomerang.range, .right([3, 5, 7, 9, 11]))

        let sightrasher = try await database.skill(forAegisName: "WZ_SIGHTRASHER")!
        XCTAssertEqual(sightrasher.id, 81)
        XCTAssertEqual(sightrasher.requires?.status, ["Sight"])
    }

    func testRenewal() async throws {
        let database = SkillDatabase.renewal

        let napalmBeat = try await database.skill(forAegisName: "MG_NAPALMBEAT")!
        XCTAssertEqual(napalmBeat.id, 11)
        XCTAssertEqual(napalmBeat.aegisName, "MG_NAPALMBEAT")
        XCTAssertEqual(napalmBeat.name, "Napalm Beat")
        XCTAssertEqual(napalmBeat.maxLevel, 10)
        XCTAssertEqual(napalmBeat.type, .magic)
        XCTAssertEqual(napalmBeat.targetType, .attack)
        XCTAssertEqual(napalmBeat.damageFlags, [.splash, .splashsplit])
        XCTAssertEqual(napalmBeat.flags, [.isautoshadowspell, .targettrap])
        XCTAssertEqual(napalmBeat.range, .left(9))

        let spearBoomerang = try await database.skill(forAegisName: "KN_SPEARBOOMERANG")!
        XCTAssertEqual(spearBoomerang.id, 59)
        XCTAssertEqual(spearBoomerang.aegisName, "KN_SPEARBOOMERANG")
        XCTAssertEqual(spearBoomerang.name, "Spear Boomerang")
        XCTAssertEqual(spearBoomerang.maxLevel, 5)
        XCTAssertEqual(spearBoomerang.type, .weapon)
        XCTAssertEqual(spearBoomerang.targetType, .attack)
        XCTAssertEqual(spearBoomerang.range, .right([3, 5, 7, 9, 11]))

        let sightrasher = try await database.skill(forAegisName: "WZ_SIGHTRASHER")!
        XCTAssertEqual(sightrasher.id, 81)
        XCTAssertEqual(sightrasher.requires?.status, ["Sight"])
    }
}
