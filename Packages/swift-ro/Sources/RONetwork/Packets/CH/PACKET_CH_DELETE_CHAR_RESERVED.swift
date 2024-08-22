//
//  PACKET_CH_DELETE_CHAR_RESERVED.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

/// See `chclif_parse_char_delete2_req` in `char_clif.cpp`
public struct PACKET_CH_DELETE_CHAR_RESERVED: EncodablePacket {
    public static var packetType: Int16 {
        0x827
    }

    public var packetLength: Int16 {
        2 + 4
    }

    public var gid: UInt32

    public init() {
        gid = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(gid)
    }
}
