//
//  PACKET_HC_DELETE_CHAR_RESERVED.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/8/14.
//

import CoreFoundation
import BinaryIO

/// See `chclif_char_delete2_ack`
public struct PACKET_HC_DELETE_CHAR_RESERVED: DecodablePacket, Sendable {
    public static var packetType: Int16 {
        0x828
    }

    public var packetLength: Int16 {
        2 + 4 + 4 + 4
    }

    public var charID: UInt32
    public var result: UInt32
    public var deletionDate: UInt32

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        charID = try decoder.decode(UInt32.self)
        result = try decoder.decode(UInt32.self)
        deletionDate = try decoder.decode(UInt32.self)

        if PACKET_VERSION_CHAR_DELETEDATE {
            deletionDate += UInt32(CFAbsoluteTimeGetCurrent())
        }
    }
}
