//
//  PACKET_HC_REFUSE_MAKECHAR.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/4/8.
//

import BinaryIO

public let HEADER_HC_REFUSE_MAKECHAR: Int16 = 0x6e

/// See `chclif_parse_createnewchar`
public struct PACKET_HC_REFUSE_MAKECHAR: BinaryDecodable, Sendable {
    public var packetType: Int16
    public var errorCode: UInt8

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        errorCode = try decoder.decode(UInt8.self)
    }
}
