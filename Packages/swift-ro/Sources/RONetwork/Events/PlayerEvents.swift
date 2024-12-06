//
//  PlayerEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/25.
//

import ROGenerated

public enum PlayerEvents {
    public struct Moved: Event {
        public let fromPosition: SIMD2<Int16>
        public let toPosition: SIMD2<Int16>

        init(packet: PACKET_ZC_NOTIFY_PLAYERMOVE) {
            let moveData = MoveData(data: packet.moveData)
            self.fromPosition = [moveData.x0, moveData.y0]
            self.toPosition = [moveData.x1, moveData.y1]
        }
    }

    public struct MessageDisplay: Event {
        public let message: String

        init(packet: PACKET_ZC_NOTIFY_PLAYERCHAT) {
            self.message = packet.message
        }
    }

    public struct StatusPropertyChanged: Event {
        public let sp: StatusProperty
        public let value: Int
        public let value2: Int

        init?(packet: PACKET_ZC_PAR_CHANGE) {
            guard let sp = StatusProperty(rawValue: Int(packet.varID)) else {
                return nil
            }
            self.sp = sp
            self.value = Int(packet.count)
            self.value2 = 0
        }

        init?(packet: PACKET_ZC_LONGPAR_CHANGE) {
            guard let sp = StatusProperty(rawValue: Int(packet.varID)) else {
                return nil
            }
            self.sp = sp
            self.value = Int(packet.amount)
            self.value2 = 0
        }

        init?(packet: PACKET_ZC_LONGLONGPAR_CHANGE) {
            guard let sp = StatusProperty(rawValue: Int(packet.varID)) else {
                return nil
            }
            self.sp = sp
            self.value = Int(packet.amount)
            self.value2 = 0
        }

        init?(packet: PACKET_ZC_STATUS_CHANGE) {
            guard let sp = StatusProperty(rawValue: Int(packet.statusID)) else {
                return nil
            }
            self.sp = sp
            self.value = Int(packet.value)
            self.value2 = 0
        }

        init?(packet: PACKET_ZC_COUPLESTATUS) {
            guard let sp = StatusProperty(rawValue: Int(packet.statusType)) else {
                return nil
            }
            self.sp = sp
            self.value = Int(packet.defaultStatus)
            self.value2 = Int(packet.plusStatus)
        }
    }

    public struct AttackRangeChanged: Event {
        public let value: Int

        init(packet: PACKET_ZC_ATTACK_RANGE) {
            self.value = Int(packet.currentAttRange)
        }
    }
}
