//
//  DeleteCharReservedMessage.swift
//  RagnarokModels
//
//  Created by Leon Li on 2026/5/9.
//

import RagnarokPackets

public struct DeleteCharReservedMessage: Sendable {
    public let messageID: Int

    public init(from packet: PACKET_HC_DELETE_CHAR3_RESERVED) {
        messageID = switch packet.result {
        case  3: 1817   // Database error
        case  4: 1818   // Must withdraw from guild
        case  5: 1819   // Must withdraw from party
        default: 1816   // Unknown error
        }
    }
}
