//
//  PACKET.CH.ENTER.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/6.
//

extension PACKET.CH {
    public struct ENTER: EncodablePacket {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x0065 = 0x0065
        }

        public static var packetType: PacketType {
            .x0065
        }

        public var aid: UInt32 = 0
        public var authCode: UInt32 = 0
        public var userLevel: UInt32 = 0
        public var clientType: UInt16 = 0
        public var sex: UInt8 = 0

        public var packetName: String {
            "PACKET_CH_ENTER"
        }

        public var packetLength: UInt16 {
            2 + 4 + 4 + 4 + 2 + 1
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(packetType)
            try encoder.encode(aid)
            try encoder.encode(authCode)
            try encoder.encode(userLevel)
            try encoder.encode(clientType)
            try encoder.encode(sex)
        }
    }
}
