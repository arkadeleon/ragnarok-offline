//
//  PACKET_HC_ACCEPT_MAKECHAR.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/4/8.
//

import BinaryIO

/// See `chclif_createnewchar`
@available(*, deprecated, message: "Use PACKET_HC_ACCEPT_MAKECHAR instead.")
public struct _PACKET_HC_ACCEPT_MAKECHAR: DecodablePacket {
    public var packetType: Int16
    public var char: CHARACTER_INFO

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        char = try decoder.decode(CHARACTER_INFO.self)
    }
}
