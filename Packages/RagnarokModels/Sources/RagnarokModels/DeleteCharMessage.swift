//
//  DeleteCharMessage.swift
//  RagnarokModels
//
//  Created by Leon Li on 2026/5/9.
//

import RagnarokPackets

public struct DeleteCharMessage: Sendable {
    public let messageID: Int

    public init(from packet: PACKET_HC_DELETE_CHAR3) {
        messageID = switch packet.result {
        case  2: 1820   // System restriction
        case  3: 1817   // Database error
        case  4: 1821   // Deletion delay not elapsed
        case  5: 1822   // Birthdate mismatch
        default: 1816   // Unknown error
        }
    }
}
