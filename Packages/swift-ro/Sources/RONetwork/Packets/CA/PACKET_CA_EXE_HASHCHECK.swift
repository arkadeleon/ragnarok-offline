//
//  PACKET_CA_EXE_HASHCHECK.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/26.
//

public struct PACKET_CA_EXE_HASHCHECK: EncodablePacket {
    public static var packetType: UInt16 {
        0x204
    }

    public var packetLength: UInt16 {
        2 + 16
    }

    public var hashValue: [UInt8]

    public init() {
        hashValue = [UInt8](repeating: 0, count: 16)
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(hashValue)
    }
}
