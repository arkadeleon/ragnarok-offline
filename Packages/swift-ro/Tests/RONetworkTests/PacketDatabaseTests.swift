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
        XCTAssertEqual(ENTRY_CZ_ENTER.packetType, 0x436)

        XCTAssertEqual(ENTRY_CZ_REQUEST_TIME.packetType, 0x360)

        XCTAssertEqual(ENTRY_CZ_CHANGE_DIRECTION.packetType, 0x361)

        XCTAssertEqual(ENTRY_CZ_REQUEST_ACT.packetType, 0x437)

        XCTAssertEqual(ENTRY_CZ_REQUEST_MOVE.packetType, 0x35f)

        XCTAssertEqual(ENTRY_CZ_ITEM_PICKUP.packetType, 0x362)

        XCTAssertEqual(ENTRY_CZ_STATUS_CHANGE.packetType, 0xbb)
    }
}
