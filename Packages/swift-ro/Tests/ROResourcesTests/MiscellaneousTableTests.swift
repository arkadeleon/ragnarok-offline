//
//  MiscellaneousTableTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2025/2/1.
//

import XCTest
@testable import ROResources

final class MiscellaneousTableTests: XCTestCase {
    func testItemRandomOptionNameTable() async throws {
        let mhp = await ItemRandomOptionNameTable.current.itemRandomOptionName(forItemRandomOptionID: 1)
        XCTAssertEqual(mhp, "MHP + %d")
    }

    func testJobNameTable() async throws {
        let warp = await JobNameTable.current.jobName(forJobID: 45)
        XCTAssertEqual(warp, "1_ETC_01")
    }

    func testMapMP3NameTable() async throws {
        let prontera = await MapMP3NameTable.current.mapMP3Name(forMapName: "prt_fild08")
        XCTAssertEqual(prontera, "12.mp3")
    }

    func testWeaponNameTable() async throws {
        let shortsword = await WeaponNameTable.current.weaponName(forWeaponID: 1)
        XCTAssertEqual(shortsword, "_단검")

        let mainGauche = await WeaponNameTable.current.realWeaponID(forWeaponID: 31)
        XCTAssertEqual(mainGauche, 1)
    }
}
