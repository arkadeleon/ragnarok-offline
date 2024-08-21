//
//  PacketDatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/8/21.
//

import XCTest
@testable import RONetwork

final class PacketDatabaseTests: XCTestCase {
    func testPacketDatabase() async throws {
        let entries = packetDatabase.entries.filter({ $0.value.functionName == "clif_parse_WantToConnection" })
        XCTAssertEqual(entries.count, 5)
    }
}
