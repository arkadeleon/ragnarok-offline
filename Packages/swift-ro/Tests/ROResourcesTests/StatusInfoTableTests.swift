//
//  StatusInfoTableTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2025/1/29.
//

import XCTest
import ROConstants
@testable import ROResources

final class StatusInfoTableTests: XCTestCase {
    let localURL = Bundle.module.resourceURL!

    func testIconName() async throws {
        let resourceManager = ResourceManager(locale: .current, localURL: localURL, remoteURL: nil)
        let scriptManager = await resourceManager.scriptManager()
        let swordclan = scriptManager.statusIconName(forStatusID: OfficialStatusChangeID.efst_swordclan.rawValue)
        XCTAssertEqual(swordclan, "SWORDCLAN.TGA")
    }

    func testLocalizedDescription() async throws {
        let resourceManager = ResourceManager(locale: .current, localURL: localURL, remoteURL: nil)
        let scriptManager = await resourceManager.scriptManager()
        let provoke = scriptManager.localizedStatusDescription(forStatusID: OfficialStatusChangeID.efst_provoke.rawValue)
        XCTAssertEqual(provoke, "프로보크(Provoke)")
    }
}
