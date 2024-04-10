//
//  PACKET.CH.DELETE_CHAR_RESERVED.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

extension PACKET.CH {
    public struct DELETE_CHAR_RESERVED: PacketProtocol {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x0827 = 0x0827
        }

        public let packetType: PacketType
        public var gid: UInt32 = 0

        public var packetName: String {
            "PACKET_CH_DELETE_CHAR_RESERVED"
        }

        public var packetLength: UInt16 {
            2 + 4
        }

        public init(packetVersion: PacketVersion) {
            packetType = .x0827
        }

        public init(from decoder: BinaryDecoder) throws {
            packetType = try decoder.decode(PacketType.self)
            gid = try decoder.decode(UInt32.self)
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(packetType)
            try encoder.encode(gid)
        }
    }
}
