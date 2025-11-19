//
//  PACKET_HC_DELETE_CHAR_CANCEL.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/8/14.
//

import BinaryIO

public let HEADER_HC_DELETE_CHAR_CANCEL: Int16 = 0x82c

/// See `chclif_char_delete2_cancel_ack`
public struct PACKET_HC_DELETE_CHAR_CANCEL: DecodablePacket {
    public var packetType: Int16
    public var charID: UInt32
    public var result: UInt32

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        charID = try decoder.decode(UInt32.self)
        result = try decoder.decode(UInt32.self)
    }
}
