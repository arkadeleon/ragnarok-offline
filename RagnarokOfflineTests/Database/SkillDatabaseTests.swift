//
//  SkillDatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/10.
//

import XCTest
import rAthenaResources
@testable import DatabaseCore

final class SkillDatabaseTests: XCTestCase {
    func testPrerenewal() async throws {
        let database = SkillDatabase(baseURL: serverResourceBaseURL, mode: .prerenewal)

        let napalmBeat = await database.skill(forAegisName: "MG_NAPALMBEAT")!
        XCTAssertEqual(napalmBeat.id, 11)
        XCTAssertEqual(napalmBeat.aegisName, "MG_NAPALMBEAT")
        XCTAssertEqual(napalmBeat.name, "Napalm Beat")
        XCTAssertEqual(napalmBeat.maxLevel, 10)
        XCTAssertEqual(napalmBeat.type, .magic)
        XCTAssertEqual(napalmBeat.targetType, .attack)
        XCTAssertEqual(napalmBeat.damageFlags, [.splash, .splashsplit])
        XCTAssertEqual(napalmBeat.flags, [.isautoshadowspell, .targettrap])
        XCTAssertEqual(napalmBeat.range, .left(9))

        let warp = await database.skill(forAegisName: "AL_WARP")!
        XCTAssertEqual(warp.id, 27)
        XCTAssertEqual(warp.aegisName, "AL_WARP")
        XCTAssertEqual(warp.name, "Warp Portal")
        XCTAssertEqual(warp.unit?.id, .warp_active)
        XCTAssertEqual(warp.unit?.alternateId, .warp_waiting)
        XCTAssertEqual(warp.unit?.interval, -1)
        XCTAssertEqual(warp.unit?.flag, [.noreiteration, .nofootset, .nooverlap])

        let vending = await database.skill(forAegisName: "MC_VENDING")!
        XCTAssertEqual(vending.id, 41)
        XCTAssertEqual(vending.aegisName, "MC_VENDING")
        XCTAssertEqual(vending.name, "Vending")
        XCTAssertEqual(vending.requires?.spCost, .left(30))
        XCTAssertEqual(vending.requires?.state, .cart)

        let spearBoomerang = await database.skill(forAegisName: "KN_SPEARBOOMERANG")!
        XCTAssertEqual(spearBoomerang.id, 59)
        XCTAssertEqual(spearBoomerang.aegisName, "KN_SPEARBOOMERANG")
        XCTAssertEqual(spearBoomerang.name, "Spear Boomerang")
        XCTAssertEqual(spearBoomerang.maxLevel, 5)
        XCTAssertEqual(spearBoomerang.type, .weapon)
        XCTAssertEqual(spearBoomerang.targetType, .attack)
        XCTAssertEqual(spearBoomerang.range, .right([3, 5, 7, 9, 11]))

        let sightrasher = await database.skill(forAegisName: "WZ_SIGHTRASHER")!
        XCTAssertEqual(sightrasher.id, 81)
        XCTAssertEqual(sightrasher.requires?.status, ["Sight"])
    }

    func testRenewal() async throws {
        let database = SkillDatabase(baseURL: serverResourceBaseURL, mode: .renewal)

        let napalmBeat = await database.skill(forAegisName: "MG_NAPALMBEAT")!
        XCTAssertEqual(napalmBeat.id, 11)
        XCTAssertEqual(napalmBeat.aegisName, "MG_NAPALMBEAT")
        XCTAssertEqual(napalmBeat.name, "Napalm Beat")
        XCTAssertEqual(napalmBeat.maxLevel, 10)
        XCTAssertEqual(napalmBeat.type, .magic)
        XCTAssertEqual(napalmBeat.targetType, .attack)
        XCTAssertEqual(napalmBeat.damageFlags, [.splash, .splashsplit])
        XCTAssertEqual(napalmBeat.flags, [.isautoshadowspell, .targettrap])
        XCTAssertEqual(napalmBeat.range, .left(9))

        let warp = await database.skill(forAegisName: "AL_WARP")!
        XCTAssertEqual(warp.id, 27)
        XCTAssertEqual(warp.aegisName, "AL_WARP")
        XCTAssertEqual(warp.name, "Warp Portal")
        XCTAssertEqual(warp.unit?.id, .warp_active)
        XCTAssertEqual(warp.unit?.alternateId, .warp_waiting)
        XCTAssertEqual(warp.unit?.interval, -1)
        XCTAssertEqual(warp.unit?.flag, [.noreiteration, .nofootset, .nooverlap])

        let vending = await database.skill(forAegisName: "MC_VENDING")!
        XCTAssertEqual(vending.id, 41)
        XCTAssertEqual(vending.aegisName, "MC_VENDING")
        XCTAssertEqual(vending.name, "Vending")
        XCTAssertEqual(vending.requires?.spCost, .left(30))
        XCTAssertEqual(vending.requires?.state, .cart)

        let spearBoomerang = await database.skill(forAegisName: "KN_SPEARBOOMERANG")!
        XCTAssertEqual(spearBoomerang.id, 59)
        XCTAssertEqual(spearBoomerang.aegisName, "KN_SPEARBOOMERANG")
        XCTAssertEqual(spearBoomerang.name, "Spear Boomerang")
        XCTAssertEqual(spearBoomerang.maxLevel, 5)
        XCTAssertEqual(spearBoomerang.type, .weapon)
        XCTAssertEqual(spearBoomerang.targetType, .attack)
        XCTAssertEqual(spearBoomerang.range, .right([3, 5, 7, 9, 11]))

        let sightrasher = await database.skill(forAegisName: "WZ_SIGHTRASHER")!
        XCTAssertEqual(sightrasher.id, 81)
        XCTAssertEqual(sightrasher.requires?.status, ["Sight"])
    }
}
