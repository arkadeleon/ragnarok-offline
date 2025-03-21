//
//  NPCDatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/10.
//

import XCTest
@testable import RODatabase

final class NPCDatabaseTests: XCTestCase {
    func testPrerenewal() async throws {
        let database = NPCDatabase.prerenewal

        let poring = await MonsterDatabase.prerenewal.monster(forAegisName: "PORING")!
        let poringMonsterSpawns = await database.monsterSpawns(forMonster: poring)
        XCTAssertEqual(poringMonsterSpawns.count, 28)

        let prtfild08MonsterSpawns = await database.monsterSpawns(forMapName: "prt_fild08")
        XCTAssertEqual(prtfild08MonsterSpawns.count, 4)
    }

    func testRenewal() async throws {
        let database = NPCDatabase.renewal

        let poring = await MonsterDatabase.renewal.monster(forAegisName: "PORING")!
        let poringMonsterSpawns = await database.monsterSpawns(forMonster: poring)
        XCTAssertEqual(poringMonsterSpawns.count, 16)

        let prtfild08MonsterSpawns = await database.monsterSpawns(forMapName: "prt_fild08")
        XCTAssertEqual(prtfild08MonsterSpawns.count, 26)
    }
}
