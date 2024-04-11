//
//  PACKET.HC.ACCEPT_ENTER_NEO_UNION.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/7.
//

extension PACKET.HC {
    public struct ACCEPT_ENTER_NEO_UNION: PacketProtocol {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x006b = 0x006b
        }

        public let packetVersion: PacketVersion
        public let packetType: PacketType
        public var totalSlotNum: UInt8 = 0
        public var premiumStartSlot: UInt8 = 0
        public var premiumEndSlot: UInt8 = 0
        public var charList: [CharInfo] = []

        public var packetName: String {
            "PACKET_HC_ACCEPT_ENTER_NEO_UNION"
        }

        public var packetLength: UInt16 {
            var packetLength: UInt16 = 2 + 2
            if packetVersion.number >= 20100413 {
                packetLength += 1 + 1 + 1
            }
            packetLength += 20
            packetLength += CharInfo.size(for: packetVersion) * UInt16(charList.count)
            return packetLength
        }

        public init(packetVersion: PacketVersion) {
            self.packetVersion = packetVersion
            packetType = .x006b
        }

        public init(from decoder: BinaryDecoder) throws {
            packetVersion = decoder.userInfo[.packetVersionKey] as! PacketVersion

            packetType = try decoder.decode(PacketType.self)

            let packetLength = try decoder.decode(UInt16.self)

            let charCount: UInt16
            if packetVersion.number >= 20100413 {
                charCount = (packetLength - 27) / CharInfo.size(for: packetVersion)
            } else {
                charCount = (packetLength - 24) / CharInfo.size(for: packetVersion)
            }

            if packetVersion.number >= 20100413 {
                totalSlotNum = try decoder.decode(UInt8.self)
                premiumStartSlot = try decoder.decode(UInt8.self)
                premiumEndSlot = try decoder.decode(UInt8.self)
            }

            _ = try decoder.decode(String.self, length: 20)

            for _ in 0..<charCount {
                let charInfo = try decoder.decode(CharInfo.self)
                charList.append(charInfo)
            }
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(packetType)
            try encoder.encode(packetLength)

            if packetVersion.number >= 20100413 {
                try encoder.encode(totalSlotNum)
                try encoder.encode(premiumStartSlot)
                try encoder.encode(premiumEndSlot)
            }

            // Unknown bytes
            try encoder.encode("", length: 20)

            for charInfo in charList {
                try encoder.encode(charInfo)
            }
        }
    }
}
