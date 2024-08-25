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

        XCTAssertEqual(packetDatabase.entryForRequestTime.packetType, 0x360)

        XCTAssertEqual(packetDatabase.entryForChangeDirection.packetType, 0x361)

        XCTAssertEqual(packetDatabase.entryForRequestAction.packetType, 0x437)

        XCTAssertEqual(packetDatabase.entryForRequestMove.packetType, 0x35f)
    }
}
