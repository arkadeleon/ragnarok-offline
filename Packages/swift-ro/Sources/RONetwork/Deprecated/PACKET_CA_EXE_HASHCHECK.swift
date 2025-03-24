//
//  PACKET_CA_EXE_HASHCHECK.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/26.
//

import ROCore

@available(*, deprecated, message: "Use generated struct instead.")
public struct _PACKET_CA_EXE_HASHCHECK: EncodablePacket {
    public var packetType: Int16 {
        0x204
    }

    public var packetLength: Int16 {
        2 + 16
    }

    public var hash: [UInt8]

    public init() {
        hash = [UInt8](repeating: 0, count: 16)
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(hash)
    }
}
