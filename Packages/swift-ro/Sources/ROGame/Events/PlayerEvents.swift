//
//  PlayerEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/25.
//

import RONetwork

public enum PlayerEvents {
    public struct Moved: Event {
        public let fromPosition: SIMD2<Int16>
        public let toPosition: SIMD2<Int16>
    }

    public struct MessageReceived: Event {
        public let message: String

        init(packet: PACKET_ZC_NOTIFY_PLAYERCHAT) {
            self.message = packet.Message
        }
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
