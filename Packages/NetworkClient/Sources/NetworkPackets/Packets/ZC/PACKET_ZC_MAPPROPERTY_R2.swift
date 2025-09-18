//
//  PACKET_ZC_MAPPROPERTY_R2.swift
//  NetworkPackets
//
//  Created by Leon Li on 2025/3/26.
//

import BinaryIO

public struct PACKET_ZC_MAPPROPERTY_R2: BinaryDecodable, Sendable {
    public var packetType: Int16
    public var type: Int16
    public var flags: UInt32

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        type = try decoder.decode(Int16.self)
        flags = try decoder.decode(UInt32.self)
    }
}
