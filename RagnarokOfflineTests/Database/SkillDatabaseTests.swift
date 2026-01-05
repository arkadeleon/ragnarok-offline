//
//  SkillDatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/10.
//

import rAthenaResources
import XCTest
@testable import RagnarokDatabase

final class SkillDatabaseTests: XCTestCase {
    func testPrerenewal() async throws {
        let database = SkillDatabase(baseURL: serverResourceBaseURL, mode: .prerenewal)
        let skills = try await database.skills()
        let skillsByAegisName = Dictionary(
            skills.map({ ($0.aegisName, $0) }),
            uniquingKeysWith: { (first, _) in first }
        )

        let napalmBeat = skillsByAegisName["MG_NAPALMBEAT"]!
        XCTAssertEqual(napalmBeat.id, 11)
        XCTAssertEqual(napalmBeat.aegisName, "MG_NAPALMBEAT")
        XCTAssertEqual(napalmBeat.name, "Napalm Beat")
        XCTAssertEqual(napalmBeat.maxLevel, 10)
        XCTAssertEqual(napalmBeat.type, .magic)
        XCTAssertEqual(napalmBeat.targetType, .attack)
        XCTAssertEqual(napalmBeat.damageFlags, [.splash, .splashsplit])
        XCTAssertEqual(napalmBeat.flags, [.isautoshadowspell, .targettrap])
        XCTAssertEqual(napalmBeat.range, .left(9))

        let warp = skillsByAegisName["AL_WARP"]!
        XCTAssertEqual(warp.id, 27)
        XCTAssertEqual(warp.aegisName, "AL_WARP")
        XCTAssertEqual(warp.name, "Warp Portal")
        XCTAssertEqual(warp.unit?.id, .warp_active)
        XCTAssertEqual(warp.unit?.alternateId, .warp_waiting)
        XCTAssertEqual(warp.unit?.interval, -1)
        XCTAssertEqual(warp.unit?.flag, [.noreiteration, .nofootset, .nooverlap])

        let vending = skillsByAegisName["MC_VENDING"]!
        XCTAssertEqual(vending.id, 41)
        XCTAssertEqual(vending.aegisName, "MC_VENDING")
        XCTAssertEqual(vending.name, "Vending")
        XCTAssertEqual(vending.requires?.spCost, .left(30))
        XCTAssertEqual(vending.requires?.state, .cart)

        let spearBoomerang = skillsByAegisName["KN_SPEARBOOMERANG"]!
        XCTAssertEqual(spearBoomerang.id, 59)
        XCTAssertEqual(spearBoomerang.aegisName, "KN_SPEARBOOMERANG")
        XCTAssertEqual(spearBoomerang.name, "Spear Boomerang")
        XCTAssertEqual(spearBoomerang.maxLevel, 5)
        XCTAssertEqual(spearBoomerang.type, .weapon)
        XCTAssertEqual(spearBoomerang.targetType, .attack)
        XCTAssertEqual(spearBoomerang.range, .right([3, 5, 7, 9, 11]))

        let sightrasher = skillsByAegisName["WZ_SIGHTRASHER"]!
        XCTAssertEqual(sightrasher.id, 81)
        XCTAssertEqual(sightrasher.requires?.status, ["Sight"])
    }

    func testRenewal() async throws {
        let database = SkillDatabase(baseURL: serverResourceBaseURL, mode: .renewal)
        let skills = try await database.skills()
        let skillsByAegisName = Dictionary(
            skills.map({ ($0.aegisName, $0) }),
            uniquingKeysWith: { (first, _) in first }
        )

        let napalmBeat = skillsByAegisName["MG_NAPALMBEAT"]!
        XCTAssertEqual(napalmBeat.id, 11)
        XCTAssertEqual(napalmBeat.aegisName, "MG_NAPALMBEAT")
        XCTAssertEqual(napalmBeat.name, "Napalm Beat")
        XCTAssertEqual(napalmBeat.maxLevel, 10)
        XCTAssertEqual(napalmBeat.type, .magic)
        XCTAssertEqual(napalmBeat.targetType, .attack)
        XCTAssertEqual(napalmBeat.damageFlags, [.splash, .splashsplit])
        XCTAssertEqual(napalmBeat.flags, [.isautoshadowspell, .targettrap])
        XCTAssertEqual(napalmBeat.range, .left(9))

        let warp = skillsByAegisName["AL_WARP"]!
        XCTAssertEqual(warp.id, 27)
        XCTAssertEqual(warp.aegisName, "AL_WARP")
        XCTAssertEqual(warp.name, "Warp Portal")
        XCTAssertEqual(warp.unit?.id, .warp_active)
        XCTAssertEqual(warp.unit?.alternateId, .warp_waiting)
        XCTAssertEqual(warp.unit?.interval, -1)
        XCTAssertEqual(warp.unit?.flag, [.noreiteration, .nofootset, .nooverlap])

        let vending = skillsByAegisName["MC_VENDING"]!
        XCTAssertEqual(vending.id, 41)
        XCTAssertEqual(vending.aegisName, "MC_VENDING")
        XCTAssertEqual(vending.name, "Vending")
        XCTAssertEqual(vending.requires?.spCost, .left(30))
        XCTAssertEqual(vending.requires?.state, .cart)

        let spearBoomerang = skillsByAegisName["KN_SPEARBOOMERANG"]!
        XCTAssertEqual(spearBoomerang.id, 59)
        XCTAssertEqual(spearBoomerang.aegisName, "KN_SPEARBOOMERANG")
        XCTAssertEqual(spearBoomerang.name, "Spear Boomerang")
        XCTAssertEqual(spearBoomerang.maxLevel, 5)
        XCTAssertEqual(spearBoomerang.type, .weapon)
        XCTAssertEqual(spearBoomerang.targetType, .attack)
        XCTAssertEqual(spearBoomerang.range, .right([3, 5, 7, 9, 11]))

        let sightrasher = skillsByAegisName["WZ_SIGHTRASHER"]!
        XCTAssertEqual(sightrasher.id, 81)
        XCTAssertEqual(sightrasher.requires?.status, ["Sight"])
    }
}
