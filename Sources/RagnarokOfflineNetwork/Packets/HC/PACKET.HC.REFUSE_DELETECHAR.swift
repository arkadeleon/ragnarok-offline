//
//  PACKET.HC.REFUSE_DELETECHAR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

extension PACKET.HC {
    public struct REFUSE_DELETECHAR: PacketProtocol {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x0070 = 0x0070
        }

        public let packetType: PacketType
        public var errorCode: UInt8 = 0

        public var packetName: String {
            "PACKET_HC_REFUSE_DELETECHAR"
        }

        public var packetLength: UInt16 {
            2 + 1
        }

        public init(packetVersion: PacketVersion) {
            packetType = .x0070
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
