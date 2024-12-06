//
//  CharEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/25.
//

public enum CharEvents {
    public struct MakeAccepted: Event {
        public let char: CharInfo

        init(packet: PACKET_HC_ACCEPT_MAKECHAR) {
            self.char = packet.char
        }
    }

    public struct MakeRefused: Event {
    }

    public struct DeleteAccepted: Event {
    }

    public struct DeleteRefused: Event {
        public let message: String

        init(packet: PACKET_HC_REFUSE_DELETECHAR) {
            self.message = ""
        }

        init(packet: PACKET_HC_DELETE_CHAR) {
            self.message = ""
        }
    }

    public struct DeleteCancelled: Event {
    }

    public struct DeletionDateResponse: Event {
        public let deletionDate: UInt32

        init(packet: PACKET_HC_DELETE_CHAR_RESERVED) {
            self.deletionDate = packet.deletionDate
        }
    }
}
