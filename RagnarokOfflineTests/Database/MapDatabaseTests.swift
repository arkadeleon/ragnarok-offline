//
//  MapDatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/10.
//

import XCTest
import rAthenaResources
@testable import DatabaseCore

final class MapDatabaseTests: XCTestCase {
    func testPrerenewal() async throws {
        let sourceURL = ServerResourceManager.shared.sourceURL
        let database = MapDatabase(sourceURL: sourceURL, mode: .prerenewal)

        let alberta = await database.map(forName: "alberta")!
        let grid = alberta.grid()!
        XCTAssertEqual(grid.xs, 280)
        XCTAssertEqual(grid.ys, 280)
    }

    func testRenewal() async throws {
        let sourceURL = ServerResourceManager.shared.sourceURL
        let database = MapDatabase(sourceURL: sourceURL, mode: .renewal)

        let alberta = await database.map(forName: "alberta")!
        let grid = alberta.grid()!
        XCTAssertEqual(grid.xs, 280)
        XCTAssertEqual(grid.ys, 280)
    }
}
