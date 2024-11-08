//
//  CharServerInfo.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/12.
//

import ROCore

public struct CharServerInfo: BinaryDecodable, Sendable {
    public var ip: UInt32
    public var port: UInt16
    public var name: String
    public var userCount: UInt16
    public var state: UInt16
    public var property: UInt16

    public init(from decoder: BinaryDecoder) throws {
        ip = try decoder.decode(UInt32.self)
        port = try decoder.decode(UInt16.self)
        name = try decoder.decodeString(20)
        userCount = try decoder.decode(UInt16.self)
        state = try decoder.decode(UInt16.self)
        property = try decoder.decode(UInt16.self)

        if PACKET_VERSION >= 20170315 {
            _ = try decoder.decodeBytes(128)
        }
    }
}
