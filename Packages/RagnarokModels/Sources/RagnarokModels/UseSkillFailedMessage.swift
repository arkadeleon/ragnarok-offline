//
//  UseSkillFailedMessage.swift
//  RagnarokModels
//
//  Created by Leon Li on 2026/9/13.
//

import RagnarokPackets

public struct UseSkillFailedMessage: Sendable {
    public let messageID: Int

    public init(from packet: PACKET_ZC_ACK_TOUSESKILL) {
        let messageID = switch packet.cause {
        case  1: 202    // SP is insufficient
        case  2: 203    // HP is insufficient
        case  3: 808    // Requirements are not met
        case  4: 219    // Skill has not cooled down yet
        case  5: 233    // Zeny is insufficient
        case  6: 239    // This weapon cannot be used
        case  7: 246    // A Red Gemstone is needed
        case  8: 247    // A Blue Gemstone is needed
        case  9: 580    // Weight is over 50%
        case 13: 1398   // Holy Water is needed
        case 83: 661    // Cannot be used on this map
        default: 285    // Skill failed
        }

        self.messageID = messageID
    }
}
