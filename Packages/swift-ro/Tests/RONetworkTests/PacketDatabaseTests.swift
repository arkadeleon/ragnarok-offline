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
        XCTAssertEqual(packetDatabase.entryForEnter.packetType, 0x436)
    }
}
