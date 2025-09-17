//
//  NPCDatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/10.
//

import XCTest
import rAthenaResources
@testable import DatabaseCore

final class NPCDatabaseTests: XCTestCase {
    func testPrerenewal() async throws {
        let sourceURL = ServerResourceManager.shared.sourceURL
        let npcDatabase = NPCDatabase(sourceURL: sourceURL, mode: .prerenewal)
        let monsterDatabase = MonsterDatabase(sourceURL: sourceURL, mode: .prerenewal)

        let poring = await monsterDatabase.monster(forAegisName: "PORING")!
        let poringMonsterSpawns = await npcDatabase.monsterSpawns(for: poring)
        XCTAssertEqual(poringMonsterSpawns.count, 28)

        let prtfild08MonsterSpawns = await npcDatabase.monsterSpawns(forMapName: "prt_fild08")
        XCTAssertEqual(prtfild08MonsterSpawns.count, 4)
    }

    func testRenewal() async throws {
        let sourceURL = ServerResourceManager.shared.sourceURL
        let npcDatabase = NPCDatabase(sourceURL: sourceURL, mode: .renewal)
        let monsterDatabase = MonsterDatabase(sourceURL: sourceURL, mode: .renewal)

        let poring = await monsterDatabase.monster(forAegisName: "PORING")!
        let poringMonsterSpawns = await npcDatabase.monsterSpawns(for: poring)
        XCTAssertEqual(poringMonsterSpawns.count, 16)

        let prtfild08MonsterSpawns = await npcDatabase.monsterSpawns(forMapName: "prt_fild08")
        XCTAssertEqual(prtfild08MonsterSpawns.count, 26)
    }
}
