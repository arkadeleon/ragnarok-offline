//
//  MapServer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/26.
//

public struct MapServer: BinaryDecodable {
    public var ip: UInt32
    public var port: UInt16

    public init(from decoder: BinaryDecoder) throws {
        ip = try decoder.decode(UInt32.self)
        port = try decoder.decode(UInt16.self)
    }
}
