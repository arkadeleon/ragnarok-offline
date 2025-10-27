//
//  MapDatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/10.
//

import rAthenaResources
import XCTest
@testable import RagnarokDatabase

final class MapDatabaseTests: XCTestCase {
    func testPrerenewal() async throws {
        let database = MapDatabase(baseURL: serverResourceBaseURL, mode: .prerenewal)

        let alberta = await database.map(forName: "alberta")!
        let grid = alberta.grid()!
        XCTAssertEqual(grid.xs, 280)
        XCTAssertEqual(grid.ys, 280)
    }

    func testRenewal() async throws {
        let database = MapDatabase(baseURL: serverResourceBaseURL, mode: .renewal)

        let alberta = await database.map(forName: "alberta")!
        let grid = alberta.grid()!
        XCTAssertEqual(grid.xs, 280)
        XCTAssertEqual(grid.ys, 280)
    }
}
