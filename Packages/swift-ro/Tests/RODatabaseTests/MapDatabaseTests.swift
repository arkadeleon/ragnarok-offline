//
//  MapDatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/10.
//

import XCTest
@testable import RODatabase

final class MapDatabaseTests: XCTestCase {
    func testPrerenewal() async throws {
        let database = MapDatabase.prerenewal

        let new_11 = await database.map(forName: "new_1-1")!
        let grid = new_11.grid()!
        let startCell = grid.cellAt(x: 53, y: 111)
        XCTAssertEqual(startCell.isWalkable, true)
    }

    func testRenewal() async throws {
        let database = MapDatabase.renewal

        let iz_int = await database.map(forName: "iz_int")!
        let grid = iz_int.grid()!
        let startCell = grid.cellAt(x: 18, y: 26)
        XCTAssertEqual(startCell.isWalkable, true)
    }
}
