//
//  PACKET.CH.SELECT_ACCESSIBLE_MAPNAME.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/9.
//

extension PACKET.CH {
    public struct SELECT_ACCESSIBLE_MAPNAME: EncodablePacket {
        public static var packetType: UInt16 {
            0x841
        }

        public var slot: UInt8 = 0
        public var mapNumber: UInt8 = 0

        public var packetName: String {
            "PACKET_CH_SELECT_ACCESSIBLE_MAPNAME"
        }

        public var packetLength: UInt16 {
            2 + 1 + 1
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(packetType)
            try encoder.encode(slot)
            try encoder.encode(mapNumber)
        }
    }
}
