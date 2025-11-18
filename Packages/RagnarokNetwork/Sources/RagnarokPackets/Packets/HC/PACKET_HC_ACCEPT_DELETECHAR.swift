//
//  PACKET_HC_ACCEPT_DELETECHAR.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/4/8.
//

import BinaryIO

public let HEADER_HC_ACCEPT_DELETECHAR: Int16 = 0x6f

/// See `chclif_parse_delchar`
public struct PACKET_HC_ACCEPT_DELETECHAR: BinaryDecodable, Sendable {
    public var packetType: Int16

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
    }
}
