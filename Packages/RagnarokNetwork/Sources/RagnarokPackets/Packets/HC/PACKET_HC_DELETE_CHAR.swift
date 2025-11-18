//
//  PACKET_HC_DELETE_CHAR.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/4/8.
//

import BinaryIO

public let HEADER_HC_DELETE_CHAR: Int16 = 0x82a

/// See `chclif_char_delete2_accept_ack`
public struct PACKET_HC_DELETE_CHAR: BinaryDecodable, Sendable {
    public var packetType: Int16
    public var charID: UInt32
    public var result: UInt32

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        charID = try decoder.decode(UInt32.self)
        result = try decoder.decode(UInt32.self)
    }
}
