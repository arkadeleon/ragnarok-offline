//
//  PACKET.CZ.PING.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

extension PACKET.CZ {
    public struct PING: PacketProtocol {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x0187 = 0x0187
        }

        public let packetType: PacketType
        public var aid: UInt32 = 0

        public var packetName: String {
            "PACKET_CZ_PING"
        }

        public var packetLength: UInt16 {
            2 + 4
        }

        public init(packetVersion: PacketVersion) {
            packetType = .x0187
        }

        public init(from decoder: BinaryDecoder) throws {
            packetType = try decoder.decode(PacketType.self)
            aid = try decoder.decode(UInt32.self)
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(packetType)
            try encoder.encode(aid)
        }
    }
}
