//
//  PACKET_HC_REFUSE_DELETECHAR.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/4/8.
//

import BinaryIO

public let HEADER_HC_REFUSE_DELETECHAR: Int16 = 0x70

/// See `chclif_refuse_delchar`
public struct PACKET_HC_REFUSE_DELETECHAR: BinaryDecodable, Sendable {
    public var packetType: Int16
    public var errorCode: UInt8

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        errorCode = try decoder.decode(UInt8.self)
    }
}
