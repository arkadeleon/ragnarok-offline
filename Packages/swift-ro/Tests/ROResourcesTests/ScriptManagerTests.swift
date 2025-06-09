//
//  ScriptManagerTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2025/3/3.
//

import XCTest
@testable import ROResources

final class ScriptManagerTests: XCTestCase {
    let scriptManager: ScriptManager = {
        let localURL = Bundle.module.resourceURL!
        let resourceManager = ResourceManager(localURL: localURL, remoteURL: nil)
        let scriptManager = ScriptManager(
            locale: .korean,
            resourceManager: resourceManager
        )
        return scriptManager
    }()

    func testItemResourceName() async throws {
        let redPotion = await scriptManager.identifiedItemResourceName(forItemID: 501)
        XCTAssertEqual(redPotion, "빨간포션")
    }

    func testAccessoryName() async throws {
        let goggles = await scriptManager.accessoryName(forAccessoryID: 1)
        XCTAssertEqual(goggles, "_고글")
    }

    func testItemRandomOptionName() async throws {
        let mhp = await scriptManager.itemRandomOptionName(forItemRandomOptionID: 1)
        XCTAssertEqual(mhp, "MHP + %d")
    }

    func testJobName() async throws {
        let etc01 = await scriptManager.jobName(forJobID: 46)
        XCTAssertEqual(etc01, "1_ETC_01")
    }

    func testRobeName() async throws {
        let wings = await scriptManager.robeName(forRobeID: 1, checkEnglish: false)
        XCTAssertEqual(wings, "천사날개")
    }

    func testShadowFactor() async throws {
        let warp = await scriptManager.shadowFactor(forJobID: 45)
        XCTAssertEqual(warp, 0)

        let chonchon = await scriptManager.shadowFactor(forJobID: 1011)
        XCTAssertEqual(chonchon, 0.5)
    }

    func testWeaponName() async throws {
        let shortsword = await scriptManager.weaponName(forWeaponID: 1)
        XCTAssertEqual(shortsword, "_단검")

        let mainGauche = await scriptManager.realWeaponID(forWeaponID: 31)
        XCTAssertEqual(mainGauche, 1)
    }
}
