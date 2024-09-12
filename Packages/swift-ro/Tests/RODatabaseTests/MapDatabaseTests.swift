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
        XCTAssertEqual(maps.count, 1239)
    }

    func testRenewal() async throws {
        let database = MapDatabase.renewal

        let maps = try await database.maps()
        XCTAssertEqual(maps.count, 1239)
    }
}
