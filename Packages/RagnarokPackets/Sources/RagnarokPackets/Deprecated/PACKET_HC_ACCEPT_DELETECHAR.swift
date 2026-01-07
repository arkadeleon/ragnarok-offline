//
//  PACKET_HC_ACCEPT_DELETECHAR.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/4/8.
//

import BinaryIO

@available(*, deprecated, message: "Use HEADER_HC_ACCEPT_DELETECHAR instead.")
public let _HEADER_HC_ACCEPT_DELETECHAR: Int16 = 0x6f

/// See `chclif_parse_delchar`
@available(*, deprecated, message: "Use PACKET_HC_ACCEPT_DELETECHAR instead.")
public struct _PACKET_HC_ACCEPT_DELETECHAR: DecodablePacket {
    public var packetType: Int16

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
    }
}
