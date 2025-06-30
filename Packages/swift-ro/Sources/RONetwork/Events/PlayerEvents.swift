//
//  PlayerEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/25.
//

import ROPackets

public enum PlayerEvents {
    public struct Moved: Event {
        public let startPosition: SIMD2<Int>
        public let endPosition: SIMD2<Int>
    }

    public struct StatusChanged: Event {
        public let status: Player.Status
    }

    public struct AttackRangeChanged: Event {
        public let value: Int

        init(packet: PACKET_ZC_ATTACK_RANGE) {
            self.value = Int(packet.currentAttRange)
        }
    }
}
