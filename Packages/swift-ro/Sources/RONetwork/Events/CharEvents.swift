//
//  CharEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/25.
//

public enum CharEvents {
    public struct MakeAccepted: Event {
        public let char: CharInfo
    }

    public struct MakeRefused: Event {
    }

    public struct DeleteAccepted: Event {
    }

    public struct DeleteRefused: Event {
        public let message: String

        init(errorCode: UInt32) {
            message = ""
        }
    }

    public struct DeleteCancelled: Event {
    }

    public struct DeletionDateResponse: Event {
        public let deletionDate: UInt32
    }
}
