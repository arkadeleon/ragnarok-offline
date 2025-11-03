//
//  PACKET_CZ_REQUEST_QUIT.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2025/10/16.
//

import BinaryIO

public struct PACKET_CZ_REQUEST_QUIT: BinaryEncodable, Sendable {
    public let packetType: Int16

    public init() {
        packetType = 0x82
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
    }
}
