//
//  PacketRegistryTests.swift
//  NetworkPacketsTests
//
//  Created by Leon Li on 2025/3/31.
//

import XCTest
@testable import NetworkPackets

final class PacketRegistryTests: XCTestCase {
    func testPacketRegistry() async throws {
        XCTAssertTrue(registeredPackets.count > 0)
    }
}
