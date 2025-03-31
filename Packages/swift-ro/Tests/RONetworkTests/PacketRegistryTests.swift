//
//  PacketRegistryTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2025/3/31.
//

import XCTest
@testable import RONetwork

final class PacketRegistryTests: XCTestCase {
    func testPacketRegistry() async throws {
        XCTAssertTrue(registeredPackets.count > 0)
    }
}
