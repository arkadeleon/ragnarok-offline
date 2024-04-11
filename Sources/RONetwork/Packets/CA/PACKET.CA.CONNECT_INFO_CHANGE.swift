//
//  PACKET.CA.CONNECT_INFO_CHANGE.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

extension PACKET.CA {
    public struct CONNECT_INFO_CHANGE: EncodablePacket {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x0200 = 0x0200
        }

        public static var packetType: PacketType {
            .x0200
        }

        public var name = ""

        public var packetName: String {
            "PACKET_CA_CONNECT_INFO_CHANGED"
        }

        public var packetLength: UInt16 {
            2 + 24
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(packetType)
            try encoder.encode(name, length: 24)
        }
    }
}
