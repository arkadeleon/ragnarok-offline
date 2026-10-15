//
//  AttackFailedMessage.swift
//  RagnarokModels
//
//  Created by Leon Li on 2026/10/15.
//

import RagnarokPackets

public struct AttackFailedMessage: Sendable {
    public let messageID: Int

    public init?(from packet: PACKET_ZC_ACTION_FAILURE) {
        let messageID: Int? = switch packet.type {
        case 0: 242     // Ammunition is needed
        case 1: 243     // Weight is too heavy to attack or use skills
        case 2: 244     // Weight is too heavy to use skills
        case 3: 245     // Ammunition has been equipped
        default: nil
        }

        guard let messageID else {
            return nil
        }

        self.messageID = messageID
    }
}
