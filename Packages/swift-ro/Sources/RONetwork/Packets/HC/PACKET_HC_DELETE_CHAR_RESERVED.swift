//
//  PACKET_HC_DELETE_CHAR_RESERVED.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/14.
//

import CoreFoundation

/// See `chclif_char_delete2_ack` in `char_clif.cpp`
public struct PACKET_HC_DELETE_CHAR_RESERVED: DecodablePacket {
    public static var packetType: Int16 {
        0x828
    }

    public var packetLength: Int16 {
        14
    }

    public var gid: UInt32
    public var result: UInt32
    public var deleteDate: UInt32

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        gid = try decoder.decode(UInt32.self)
        result = try decoder.decode(UInt32.self)
        deleteDate = try decoder.decode(UInt32.self)

        if PACKET_VERSION_CHAR_DELETEDATE {
            deleteDate += UInt32(CFAbsoluteTimeGetCurrent())
        }
    }
}
