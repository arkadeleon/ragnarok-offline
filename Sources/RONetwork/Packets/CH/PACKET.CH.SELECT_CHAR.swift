//
//  PACKET.CH.SELECT_CHAR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/6.
//

extension PACKET.CH {
    public struct SELECT_CHAR: EncodablePacket {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x0066 = 0x0066
        }

        public static var packetType: PacketType {
            .x0066
        }

        public var charNum: UInt8 = 0

        public var packetName: String {
            "PACKET_CH_SELECT_CHAR"
        }

        public var packetLength: UInt16 {
            2 + 1
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(packetType)
            try encoder.encode(charNum)
        }
    }
}
