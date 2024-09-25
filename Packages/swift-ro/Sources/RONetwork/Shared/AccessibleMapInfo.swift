//
//  AccessibleMapInfo.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/25.
//

public struct AccessibleMapInfo: BinaryDecodable, Sendable {
    public var status: UInt32
    public var mapName: String

    public init(from decoder: BinaryDecoder) throws {
        status = try decoder.decode(UInt32.self)
        mapName = try decoder.decode(String.self, length: 16)
    }
}
