//
//  PACKET_CZ_ENTER.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/8/22.
//

import BinaryIO

let ENTRY_CZ_ENTER = packetDatabase.entry(forFunctionName: "clif_parse_WantToConnection")!

public struct PACKET_CZ_ENTER: EncodablePacket {
    public let packetType: Int16
    public var accountID: UInt32
    public var charID: UInt32
    public var loginID1: UInt32
    public var clientTime: UInt32
    public var sex: UInt8

    public init() {
        packetType = ENTRY_CZ_ENTER.packetType
        accountID = 0
        charID = 0
        loginID1 = 0
        clientTime = 0
        sex = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        let packetLength = ENTRY_CZ_ENTER.packetLength
        let offsets = ENTRY_CZ_ENTER.offsets

        var data = [UInt8](repeating: 0, count: Int(packetLength))
        data.replaceSubrange(from: 0, with: packetType)
        data.replaceSubrange(from: offsets[0], with: accountID)
        data.replaceSubrange(from: offsets[1], with: charID)
        data.replaceSubrange(from: offsets[2], with: loginID1)
        data.replaceSubrange(from: offsets[3], with: clientTime)
        data.replaceSubrange(from: offsets[4], with: sex)

        try encoder.encode(data)
    }
}
