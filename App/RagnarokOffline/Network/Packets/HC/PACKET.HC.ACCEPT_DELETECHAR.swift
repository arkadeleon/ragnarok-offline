//
//  PACKET.HC.ACCEPT_DELETECHAR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

extension PACKET.HC {
    public struct ACCEPT_DELETECHAR: PacketProtocol {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x006f = 0x006f
        }

        public let packetType: PacketType

        public var packetName: String {
            "PACKET_HC_ACCEPT_DELETECHAR"
        }

        public var packetLength: UInt16 {
            2
        }

        public init(packetVersion: PacketVersion) {
            packetType = .x006f
        }

        public init(from decoder: BinaryDecoder) throws {
            packetType = try decoder.decode(PacketType.self)
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(packetType)
        }
    }
}
