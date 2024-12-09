//
//  AuthenticationEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/25.
//

import ROGenerated
import ROLocalizations

public enum AuthenticationEvents {
    public struct Banned: Event {
        public let message: String

        init(packet: PACKET_SC_NOTIFY_BAN) {
            let messageCode = switch packet.result {
            case   0: 3     // Server closed
            case   1: 4     // Server closed
            case   2: 5     // Someone has already logged in with this id
            case   3: 9     // Sync error ?
            case   4: 439   // Server is jammed due to overpopulation.
            case   5: 305   // You are underaged and cannot join this server.
            case   6: 764   // Trial players can't connect Pay to Play Server. (761)
            case   8: 440   // Server still recognizes your last login
            case   9: 529   // IP capacity of this Internet Cafe is full. Would you like to pay the personal base?
            case  10: 530   // You are out of available paid playing time. Game will be shut down automatically. (528)
            case  15: 579   // You have been forced to disconnect by the Game Master Team
            case 101: 810   // Account has been locked for a hacking investigation.
            case 102: 1179  // More than 10 connections sharing the same IP have logged into the game for an hour. (1176)
            default : 3
            }

            self.message = MessageStringTable.shared.localizedMessageString(at: messageCode)
        }
    }
}
