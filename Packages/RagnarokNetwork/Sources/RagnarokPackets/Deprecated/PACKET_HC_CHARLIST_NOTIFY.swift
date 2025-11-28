//
//  PACKET_HC_CHARLIST_NOTIFY.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/8/12.
//

import BinaryIO

@available(*, deprecated, message: "Use HEADER_HC_CHARLIST_NOTIFY instead.")
public let _HEADER_HC_CHARLIST_NOTIFY: Int16 = 0x9a0

/// See `chclif_charlist_notify`
@available(*, deprecated, message: "Use PACKET_HC_CHARLIST_NOTIFY instead.")
public struct _PACKET_HC_CHARLIST_NOTIFY: DecodablePacket {
    public var packetType: Int16
    public var totalCount: UInt32
    public var charSlots: UInt32

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        totalCount = try decoder.decode(UInt32.self)

        if PACKET_VERSION_RE && PACKET_VERSION >= 20151001 && PACKET_VERSION < 20180103 {
            charSlots = try decoder.decode(UInt32.self)
        } else {
            charSlots = 0
        }
    }
}
