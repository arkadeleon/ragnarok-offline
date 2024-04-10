//
//  PACKET.HC.DELETE_CHAR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

extension PACKET.HC {
    public struct DELETE_CHAR: PacketProtocol {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x082a = 0x082a
        }

        public let packetType: PacketType
        public var aid: UInt32 = 0
        public var result: UInt32 = 0

        public var packetName: String {
            "PACKET_HC_DELETE_CHAR"
        }

        public var packetLength: UInt16 {
            2 + 4 + 4
        }

        public init(packetVersion: PacketVersion) {
            packetType = .x082a
        }

        public init(from decoder: BinaryDecoder) throws {
            packetType = try decoder.decode(PacketType.self)
            aid = try decoder.decode(UInt32.self)
            result = try decoder.decode(UInt32.self)
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(packetType)
            try encoder.encode(aid)
            try encoder.encode(result)
        }
    }
}
