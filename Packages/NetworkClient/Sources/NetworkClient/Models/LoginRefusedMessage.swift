//
//  LoginRefusedMessage.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/6/30.
//

import NetworkPackets

public struct LoginRefusedMessage: Sendable {
    public let messageID: Int
    public let unblockTime: String

    init(packet: PACKET_AC_REFUSE_LOGIN) {
        let messageID = switch packet.error {
        case   0: 6     // Unregistered ID
        case   1: 7     // Incorrect Password
        case   2: 8     // This ID is expired
        case   3: 3     // Rejected from Server
        case   4: 266   // Checked: 'Login is currently unavailable. Please try again shortly.'- 2br
        case   5: 310   // Your Game's EXE file is not the latest version
        case   6: 449   // Your are Prohibited to log in until %s
        case   7: 264   // Server is jammed due to over populated
        case   8: 681   // Checked: 'This account can't connect the Sakray server.'
        case   9: 703   // 9 = MSI_REFUSE_BAN_BY_DBA
        case  10: 704   // 10 = MSI_REFUSE_EMAIL_NOT_CONFIRMED
        case  11: 705   // 11 = MSI_REFUSE_BAN_BY_GM
        case  12: 706   // 12 = MSI_REFUSE_TEMP_BAN_FOR_DBWORK
        case  13: 707   // 13 = MSI_REFUSE_SELF_LOCK
        case  14: 708   // 14 = MSI_REFUSE_NOT_PERMITTED_GROUP
        case  15: 709   // 15 = MSI_REFUSE_NOT_PERMITTED_GROUP
        case  99: 368   // 99 = This ID has been totally erased
        case 100: 809   // 100 = Login information remains at %s
        case 101: 810   // 101 = Account has been locked for a hacking investigation. Please contact the GM Team for more information
        case 102: 811   // 102 = This account has been temporarily prohibited from login due to a bug-related investigation
        case 103: 859   // 103 = This character is being deleted. Login is temporarily unavailable for the time being
        case 104: 860   // 104 = This character is being deleted. Login is temporarily unavailable for the time being
        default : 9
        }

        self.messageID = messageID
        self.unblockTime = packet.unblock_time
    }
}
