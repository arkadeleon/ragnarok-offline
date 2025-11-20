//
//  CharacterEvents.swift
//  RagnarokNetwork
//
//  Created by Leon Li on 2024/9/25.
//

public enum CharacterEvents {
    public struct MakeAccepted: Event {
        public let character: CharacterInfo
    }

    public struct MakeRefused: Event {
    }

    public struct DeleteAccepted: Event {
    }

    public struct DeleteRefused: Event {
        public let message: String
    }

    public struct DeleteCancelled: Event {
    }

    public struct DeletionDateResponse: Event {
        public let deletionDate: UInt32
    }
}
