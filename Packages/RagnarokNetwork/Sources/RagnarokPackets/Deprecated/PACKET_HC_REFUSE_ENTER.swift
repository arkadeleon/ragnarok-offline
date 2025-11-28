//
//  PACKET_HC_REFUSE_ENTER.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/4/8.
//

import BinaryIO

@available(*, deprecated, message: "Use HEADER_HC_REFUSE_ENTER instead.")
public let _HEADER_HC_REFUSE_ENTER: Int16 = 0x6c

/// See `chclif_reject`
@available(*, deprecated, message: "Use PACKET_HC_REFUSE_ENTER instead.")
public struct _PACKET_HC_REFUSE_ENTER: DecodablePacket {
    public var packetType: Int16
    public var errorCode: UInt8

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        errorCode = try decoder.decode(UInt8.self)
    }
}
