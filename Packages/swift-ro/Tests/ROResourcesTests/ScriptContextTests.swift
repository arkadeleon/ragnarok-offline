//
//  ScriptContextTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2025/3/3.
//

import XCTest
import ROCore
@testable import ROResources

final class ScriptContextTests: XCTestCase {
    var scriptContext: ScriptContext {
        get async {
            let localURL = Bundle.module.resourceURL!
            let resourceManager = ResourceManager(locale: .korean, localURL: localURL, remoteURL: nil)
            let scriptContext = await resourceManager.scriptContext()
            return scriptContext
        }
    }

    func testItemResourceName() async throws {
        let redPotion = await scriptContext.identifiedItemResourceName(forItemID: 501)
        XCTAssertEqual(redPotion, K2L("빨간포션"))
    }

    func testAccessoryName() async throws {
        let goggles = await scriptContext.accessoryName(forAccessoryID: 1)
        XCTAssertEqual(goggles, K2L("_고글"))
    }

    func testItemRandomOptionName() async throws {
        let mhp = await scriptContext.localizedItemRandomOptionName(forItemRandomOptionID: 1)
        XCTAssertEqual(mhp, "MHP + %d")
    }

    func testJobName() async throws {
        let etc01 = await scriptContext.jobName(forJobID: 46)
        XCTAssertEqual(etc01, "1_ETC_01")
    }

    func testRobeName() async throws {
        let wings = await scriptContext.robeName(forRobeID: 1, checkEnglish: false)
        XCTAssertEqual(wings, K2L("천사날개"))
    }

    func testShadowFactor() async throws {
        let warp = await scriptContext.shadowFactor(forJobID: 45)
        XCTAssertEqual(warp, 0)

        let chonchon = await scriptContext.shadowFactor(forJobID: 1011)
        XCTAssertEqual(chonchon, 0.5)
    }

    func testWeaponName() async throws {
        let shortsword = await scriptContext.weaponName(forWeaponID: 1)
        XCTAssertEqual(shortsword, K2L("_단검"))

        let mainGauche = await scriptContext.realWeaponID(forWeaponID: 31)
        XCTAssertEqual(mainGauche, 1)
    }
}
