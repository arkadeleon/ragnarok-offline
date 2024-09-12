//
//  NPCDatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/10.
//

import XCTest
import rAthenaResources
@testable import RODatabase

final class NPCDatabaseTests: XCTestCase {
    override func setUp() async throws {
        try ServerResourceManager.default.prepareForServers()
    }

    func testPrerenewal() async throws {
        let database = NPCDatabase.prerenewal

        let poring = try await MonsterDatabase.prerenewal.monster(forAegisName: "PORING")!
        let poringMonsterSpawns = try await database.monsterSpawns(forMonster: poring)
        XCTAssertEqual(poringMonsterSpawns.count, 28)

        let prtfild08 = try await MapDatabase.prerenewal.map(forName: "prt_fild08")!
        let prtfild08MonsterSpawns = try await database.monsterSpawns(forMap: prtfild08)
        XCTAssertEqual(prtfild08MonsterSpawns.count, 4)
    }

    func testRenewal() async throws {
        let database = NPCDatabase.renewal

        let poring = try await MonsterDatabase.renewal.monster(forAegisName: "PORING")!
        let poringMonsterSpawns = try await database.monsterSpawns(forMonster: poring)
        XCTAssertEqual(poringMonsterSpawns.count, 16)

        let prtfild08 = try await MapDatabase.renewal.map(forName: "prt_fild08")!
        let prtfild08MonsterSpawns = try await database.monsterSpawns(forMap: prtfild08)
        XCTAssertEqual(prtfild08MonsterSpawns.count, 26)
    }
}
