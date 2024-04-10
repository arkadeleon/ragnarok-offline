//
//  PACKET.CH.SELECT_CHAR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/6.
//

extension PACKET.CH {
    public struct SELECT_CHAR: PacketProtocol {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x0066 = 0x0066
        }

        public let packetType: PacketType
        public var charNum: UInt8 = 0

        public var packetName: String {
            "PACKET_CH_SELECT_CHAR"
        }

        public var packetLength: UInt16 {
            2 + 1
        }

        public init(packetVersion: PacketVersion) {
            packetType = .x0066
        }

        public init(from decoder: BinaryDecoder) throws {
            packetType = try decoder.decode(PacketType.self)
            charNum = try decoder.decode(UInt8.self)
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(packetType)
            try encoder.encode(charNum)
        }
    }
}
