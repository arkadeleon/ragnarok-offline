//
//  PACKET_HC_DELETE_CHAR_RESERVED.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/8/14.
//

import BinaryIO
import CoreFoundation

public let HEADER_HC_DELETE_CHAR_RESERVED: Int16 = 0x828

/// See `chclif_char_delete2_ack`
public struct PACKET_HC_DELETE_CHAR_RESERVED: BinaryDecodable, Sendable {
    public var packetType: Int16
    public var charID: UInt32
    public var result: UInt32
    public var deletionDate: UInt32

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        charID = try decoder.decode(UInt32.self)
        result = try decoder.decode(UInt32.self)
        deletionDate = try decoder.decode(UInt32.self)

        if PACKET_VERSION_CHAR_DELETEDATE {
            deletionDate += UInt32(CFAbsoluteTimeGetCurrent())
        }
    }
}
