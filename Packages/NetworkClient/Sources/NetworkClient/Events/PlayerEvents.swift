//
//  PlayerEvents.swift
//  NetworkClient
//
//  Created by Leon Li on 2024/9/25.
//

public enum PlayerEvents {
    public struct Moved: Event {
        public let startPosition: SIMD2<Int>
        public let endPosition: SIMD2<Int>
    }

    public struct StatusChanged: Event {
        public let status: CharacterStatus
    }

    public struct AttackRangeChanged: Event {
        public let value: Int
    }
}
