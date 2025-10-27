//
//  PACKET_CZ_REQUEST_TIME.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/8/23.
//

import BinaryIO

let ENTRY_CZ_REQUEST_TIME = packetDatabase.entry(forFunctionName: "clif_parse_TickSend")!

public struct PACKET_CZ_REQUEST_TIME: BinaryEncodable {
    public let packetType: Int16
    public var clientTime: UInt32

    public init() {
        packetType = ENTRY_CZ_REQUEST_TIME.packetType
        clientTime = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        let packetLength = ENTRY_CZ_REQUEST_TIME.packetLength
        let offsets = ENTRY_CZ_REQUEST_TIME.offsets

        var data = [UInt8](repeating: 0, count: Int(packetLength))
        data.replaceSubrange(from: 0, with: packetType)
        data.replaceSubrange(from: offsets[0], with: clientTime)

        try encoder.encode(data)
    }
}
