//
//  DatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/1/9.
//

import XCTest
import rAthenaResource
@testable import RODatabase

final class DatabaseTests: XCTestCase {
    let database = Database.renewal

    override func setUp() async throws {
        try await ResourceBundle.shared.load()
    }

    func testMonsterSpawnDatabase() async throws {
        let poring = try await MonsterDatabase.renewal.monster(forAegisName: "PORING")
        let poringMonsterSpawns = try await database.monsterSpawns(forMonster: poring)
        XCTAssertEqual(poringMonsterSpawns.count, 15)

        let prtfild08 = try await MapDatabase.renewal.map(forName: "prt_fild08")
        let prtfild08MonsterSpawns = try await database.monsterSpawns(forMap: prtfild08)
        XCTAssertEqual(prtfild08MonsterSpawns.count, 6)
    }
}
