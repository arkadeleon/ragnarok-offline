//
//  MiscellaneousTableTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2025/2/1.
//

import XCTest
@testable import ROResources

final class MiscellaneousTableTests: XCTestCase {
    func testAccessoryNameTable() async throws {
        let goggles = await accessoryNameTable.accessoryName(forAccessoryID: 1)
        XCTAssertEqual(goggles, "_고글")
    }

    func testItemRandomOptionNameTable() async throws {
        let mhp = await itemRandomOptionNameTable.itemRandomOptionName(forItemRandomOptionID: 1)
        XCTAssertEqual(mhp, "MHP + %d")
    }

    func testJobNameTable() async throws {
        let warp = await jobNameTable.jobName(forJobID: 45)
        XCTAssertEqual(warp, "1_ETC_01")
    }

    func testMapMP3NameTable() async throws {
        let prontera = await mapMP3NameTable.mapMP3Name(forMapName: "prt_fild08")
        XCTAssertEqual(prontera, "12.mp3")
    }

    func testRobeNameTable() async throws {
        let wings = await robeNameTable.robeName(forRobeID: 1)
        XCTAssertEqual(wings, "천사날개")
    }

    func testShadowFactorTable() async throws {
        let warp = await shadowFactorTable.shadowFactor(forJobID: 45)
        XCTAssertEqual(warp, 0)
    }

    func testWeaponNameTable() async throws {
        let shortsword = await weaponNameTable.weaponName(forWeaponID: 1)
        XCTAssertEqual(shortsword, "_단검")
    }
}
