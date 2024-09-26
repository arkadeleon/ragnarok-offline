//
//  PlayerEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/25.
//

import ROGenerated

public enum PlayerEvents {
    public struct Moved: Event {
        public let moveData: MoveData
    }

    public struct MessageDisplay: Event {
        public let message: String

        init(message: [UInt8]) {
            self.message = String(bytes: message, encoding: .isoLatin1) ?? ""
        }
    }

    public struct StatusPropertyChanged: Event {
        public let sp: StatusProperty
        public let value: Int
        public let value2: Int
    }

    public struct AttackRangeChanged: Event {
        public let value: Int
    }
}
