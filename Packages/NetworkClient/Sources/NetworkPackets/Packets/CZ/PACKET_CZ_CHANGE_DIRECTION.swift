//
//  PACKET_CZ_CHANGE_DIRECTION.swift
//  NetworkPackets
//
//  Created by Leon Li on 2024/8/22.
//

import BinaryIO

let ENTRY_CZ_CHANGE_DIRECTION = packetDatabase.entry(forFunctionName: "clif_parse_ChangeDir")!

public struct PACKET_CZ_CHANGE_DIRECTION: BinaryEncodable {
    public let packetType: Int16
    public var headDirection: UInt16
    public var direction: UInt8

    public init() {
        packetType = ENTRY_CZ_CHANGE_DIRECTION.packetType
        headDirection = 0
        direction = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        let packetLength = ENTRY_CZ_CHANGE_DIRECTION.packetLength
        let offsets = ENTRY_CZ_CHANGE_DIRECTION.offsets

        var data = [UInt8](repeating: 0, count: Int(packetLength))
        data.replaceSubrange(from: 0, with: packetType)
        data.replaceSubrange(from: offsets[0], with: headDirection)
        data.replaceSubrange(from: offsets[1], with: direction)

        try encoder.encode(data)
    }
}
