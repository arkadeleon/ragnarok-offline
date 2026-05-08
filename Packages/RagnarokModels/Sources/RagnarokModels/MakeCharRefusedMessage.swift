//
//  MakeCharRefusedMessage.swift
//  RagnarokModels
//
//  Created by Leon Li on 2025/5/8.
//

import RagnarokPackets

public struct MakeCharRefusedMessage: Sendable {
    public let messageID: Int

    public init(from packet: PACKET_HC_REFUSE_MAKECHAR) {
        messageID = switch packet.error {
        case 0x00: 10   // Charname already exists
        case 0x01: 298  // You are underaged
        case 0x02: 1272 // Symbols in Character Names are forbidden
        case 0x03: 1355 // You are not eligible to open the Character Slot
        case 0xff: 11   // Char creation denied
        default:   11   // Char creation denied
        }
    }
}
