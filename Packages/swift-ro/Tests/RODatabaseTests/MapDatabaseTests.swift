//
//  MapDatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/10.
//

import XCTest
import rAthenaResources
@testable import RODatabase

final class MapDatabaseTests: XCTestCase {
    override func setUp() async throws {
        try ServerResourceManager.default.prepareForServers()
    }

    func testPrerenewal() async throws {
        let database = MapDatabase.prerenewal

        let maps = try await database.maps()
        XCTAssertEqual(maps.count, 1247)

        let new_11 = try await database.map(forName: "new_1-1")!
        let grid = new_11.grid()!
        let startCell = grid.cell(atX: 53, y: 111)
        XCTAssertEqual(startCell.isWalkable, true)
    }

    func testRenewal() async throws {
        let database = MapDatabase.renewal

        let maps = try await database.maps()
        XCTAssertEqual(maps.count, 1247)

        let iz_int = try await database.map(forName: "iz_int")!
        let grid = iz_int.grid()!
        let startCell = grid.cell(atX: 18, y: 26)
        XCTAssertEqual(startCell.isWalkable, true)
    }
}
