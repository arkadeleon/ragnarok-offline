//
//  PACKET.CA.CONNECT_INFO_CHANGE.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

extension PACKET.CA {
    public struct CONNECT_INFO_CHANGE: PacketProtocol {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x0200 = 0x0200
        }

        public let packetType: PacketType
        public var name = ""

        public var packetName: String {
            "PACKET_CA_CONNECT_INFO_CHANGED"
        }

        public var packetLength: UInt16 {
            2 + 24
        }

        public init(packetVersion: PacketVersion) {
            packetType = .x0200
        }

        public init(from decoder: BinaryDecoder) throws {
            packetType = try decoder.decode(PacketType.self)
            name = try decoder.decode(String.self, length: 24)
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(packetType)
            try encoder.encode(name, length: 24)
        }
    }
}
