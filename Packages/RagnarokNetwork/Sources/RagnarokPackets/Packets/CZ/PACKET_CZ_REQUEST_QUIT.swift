//
//  PACKET_CZ_REQUEST_QUIT.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2025/10/16.
//

import BinaryIO

public let HEADER_CZ_REQUEST_QUIT: Int16 = 0x82

public struct PACKET_CZ_REQUEST_QUIT: BinaryEncodable, Sendable {
    public var packetType: Int16 = 0

    public init() {
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
    }
}
