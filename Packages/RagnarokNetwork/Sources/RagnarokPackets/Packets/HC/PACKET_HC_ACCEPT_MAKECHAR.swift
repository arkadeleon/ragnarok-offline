//
//  PACKET_HC_ACCEPT_MAKECHAR.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/4/8.
//

import BinaryIO

/// See `chclif_parse_createnewchar`
public struct PACKET_HC_ACCEPT_MAKECHAR: DecodablePacket {
    public var packetType: Int16
    public var char: CHARACTER_INFO

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        char = try decoder.decode(CHARACTER_INFO.self)
    }
}
