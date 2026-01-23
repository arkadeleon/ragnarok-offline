//
//  PacketRegistryTests.swift
//  RagnarokPacketsTests
//
//  Created by Leon Li on 2025/3/31.
//

import XCTest
@testable import RagnarokPackets

final class PacketRegistryTests: XCTestCase {
    func testPacketRegistry() async throws {
        XCTAssertEqual(registeredPackets.count, 380)
    }
}
