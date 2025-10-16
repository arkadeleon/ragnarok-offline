//
//  PACKET_ZC_ACK_REQ_DISCONNECT.swift
//  NetworkPackets
//
//  Created by Leon Li on 2025/10/16.
//

import BinaryIO

public let HEADER_ZC_ACK_REQ_DISCONNECT: Int16 = 0x18b

// See `clif_disconnect_ack`
public struct PACKET_ZC_ACK_REQ_DISCONNECT: BinaryDecodable, Sendable {
    public var packetType: Int16
    public var result: UInt16

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        result = try decoder.decode(UInt16.self)
    }
}
