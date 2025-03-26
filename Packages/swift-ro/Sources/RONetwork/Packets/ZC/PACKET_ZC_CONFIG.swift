//
//  PACKET_ZC_CONFIG.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/26.
//

import ROCore

public let HEADER_ZC_CONFIG: Int16 = 0x2d9

public struct PACKET_ZC_CONFIG: BinaryDecodable {
    public var packetType: Int16
    public var type: Int32
    public var value: Int32

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        type = try decoder.decode(Int32.self)
        value = try decoder.decode(Int32.self)
    }
}
