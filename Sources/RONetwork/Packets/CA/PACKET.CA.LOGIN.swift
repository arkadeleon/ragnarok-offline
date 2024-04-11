//
//  PACKET.CA.LOGIN.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/5.
//

extension PACKET.CA {
    public struct LOGIN: EncodablePacket {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x0064 = 0x0064
        }

        public static var packetType: PacketType {
            .x0064
        }

        public var version: UInt32 = 0
        public var username = ""
        public var password = ""
        public var clientType: UInt8 = 0

        public var packetName: String {
            "PACKET_CA_LOGIN"
        }

        public var packetLength: UInt16 {
            2 + 4 + 24 + 24 + 1
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(packetType)
            try encoder.encode(version)
            try encoder.encode(username, length: 24)
            try encoder.encode(password, length: 24)
            try encoder.encode(clientType)
        }
    }
}
