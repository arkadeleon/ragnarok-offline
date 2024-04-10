//
//  PACKET.CH.ENTER.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/6.
//

extension PACKET.CH {
    public struct ENTER: PacketProtocol {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x0065 = 0x0065
        }

        public let packetType: PacketType
        public var aid: UInt32 = 0
        public var authCode: UInt32 = 0
        public var userLevel: UInt32 = 0
        public var clientType: UInt16 = 0
        public var sex: UInt8 = 0

        public var packetName: String {
            "PACKET_CH_ENTER"
        }

        public var packetLength: UInt16 {
            2 + 4 + 4 + 4 + 2 + 1
        }

        public init(packetVersion: PacketVersion) {
            packetType = .x0065
        }

        public init(from decoder: BinaryDecoder) throws {
            packetType = try decoder.decode(PacketType.self)
            aid = try decoder.decode(UInt32.self)
            authCode = try decoder.decode(UInt32.self)
            userLevel = try decoder.decode(UInt32.self)
            clientType = try decoder.decode(UInt16.self)
            sex = try decoder.decode(UInt8.self)
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(packetType)
            try encoder.encode(aid)
            try encoder.encode(authCode)
            try encoder.encode(userLevel)
            try encoder.encode(clientType)
            try encoder.encode(sex)
        }
    }
}
