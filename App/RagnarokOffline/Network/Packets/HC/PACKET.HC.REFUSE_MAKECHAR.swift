//
//  PACKET.HC.REFUSE_MAKECHAR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

extension PACKET.HC {
    public struct REFUSE_MAKECHAR: PacketProtocol {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x006e = 0x006e
        }

        public let packetType: PacketType
        public var errorCode: UInt8 = 0

        public var packetName: String {
            "PACKET_HC_REFUSE_MAKECHAR"
        }

        public var packetLength: UInt16 {
            2 + 1
        }

        public init(packetVersion: PacketVersion) {
            packetType = .x006e
        }

        public init(from decoder: BinaryDecoder) throws {
            packetType = try decoder.decode(PacketType.self)
            errorCode = try decoder.decode(UInt8.self)
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(packetType)
            try encoder.encode(errorCode)
        }
    }
}
