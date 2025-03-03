//
//  ScriptManagerTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2025/3/3.
//

import XCTest
@testable import ROResources

final class ScriptManagerTests: XCTestCase {
    let scriptManager = ScriptManager(
        resourceManager: ResourceManager(baseURL: Bundle.module.resourceURL!)
    )

    func testAccessoryNameTable() async throws {
        let goggles = await scriptManager.accessoryName(forAccessoryID: 1)
        XCTAssertEqual(goggles, "_고글")
    }

    func testJobNameTable() async throws {
        let warp = await scriptManager.jobName(forJobID: 45)
        XCTAssertEqual(warp, "1_ETC_01")
    }

    func testRobeNameTable() async throws {
        let wings = await scriptManager.robeName(forRobeID: 1, checkEnglish: false)
        XCTAssertEqual(wings, "천사날개")
    }

    func testShadowFactorTable() async throws {
        let warp = await scriptManager.shadowFactor(forJobID: 45)
        XCTAssertEqual(warp, 0)

        let chonchon = await scriptManager.shadowFactor(forJobID: 1011)
        XCTAssertEqual(chonchon, 0.5)
    }

    func testWeaponNameTable() async throws {
        let shortsword = await scriptManager.weaponName(forWeaponID: 1)
        XCTAssertEqual(shortsword, "_단검")

        let mainGauche = await scriptManager.realWeaponID(forWeaponID: 31)
        XCTAssertEqual(mainGauche, 1)
    }
}
