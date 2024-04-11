//
//  PACKET.HC.ACCEPT_MAKECHAR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

extension PACKET.HC {
    public struct ACCEPT_MAKECHAR: PacketProtocol {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x006d = 0x006d
            case x0b6f = 0x0b6f
        }

        public let packetVersion: PacketVersion
        public let packetType: PacketType
        public var charInfo: CharInfo

        public var packetName: String {
            "PACKET_HC_ACCEPT_MAKECHAR"
        }

        public var packetLength: UInt16 {
            2 + CharInfo.size(for: packetVersion)
        }

        public init(packetVersion: PacketVersion) {
            self.packetVersion = packetVersion
            if packetVersion.mainNumber >= 20201007 || packetVersion.reNumber >= 20211103 {
                packetType = .x0b6f
            } else {
                packetType = .x006d
            }
            charInfo = CharInfo(packetVersion: packetVersion)
        }

        public init(from decoder: BinaryDecoder) throws {
            packetVersion = decoder.userInfo[.packetVersionKey] as! PacketVersion
            packetType = try decoder.decode(PacketType.self)
            charInfo = try decoder.decode(CharInfo.self)
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(packetType)
            try encoder.encode(charInfo)
        }
    }
}
