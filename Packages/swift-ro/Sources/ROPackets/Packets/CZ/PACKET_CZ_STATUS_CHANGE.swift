//
//  PACKET_CZ_STATUS_CHANGE.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/9.
//

import ROCore

let ENTRY_CZ_STATUS_CHANGE = packetDatabase.entry(forFunctionName: "clif_parse_StatusUp")!

public struct PACKET_CZ_STATUS_CHANGE: BinaryEncodable {
    public let packetType: Int16
    public var statusID: Int16
    public var amount: Int8

    public init() {
        packetType = ENTRY_CZ_STATUS_CHANGE.packetType
        statusID = 0
        amount = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        let packetLength = ENTRY_CZ_STATUS_CHANGE.packetLength
        let offsets = ENTRY_CZ_STATUS_CHANGE.offsets

        var data = [UInt8](repeating: 0, count: Int(packetLength))
        data.replaceSubrange(from: 0, with: packetType)
        data.replaceSubrange(from: offsets[0], with: statusID)
        data.replaceSubrange(from: offsets[1], with: amount)

        try encoder.encode(data)
    }
}
