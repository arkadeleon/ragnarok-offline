//
//  PACKET.HC.ACCEPT_ENTER_NEO_UNION.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/7.
//

extension PACKET.HC {
    public struct ACCEPT_ENTER_NEO_UNION: DecodablePacket {
        public static var packetType: UInt16 {
            0x6b
        }

        public var totalSlotNum: UInt8
        public var premiumStartSlot: UInt8
        public var premiumEndSlot: UInt8
        public var charList: [CharInfo]

        public var packetName: String {
            "PACKET_HC_ACCEPT_ENTER_NEO_UNION"
        }

        public var packetLength: UInt16 {
            var packetLength: UInt16 = 2 + 2
            if PACKET_VERSION >= 20100413 {
                packetLength += 1 + 1 + 1
            }
            packetLength += 20
            packetLength += CharInfo.size * UInt16(charList.count)
            return packetLength
        }

        public init(from decoder: BinaryDecoder) throws {
            try decoder.decodePacketType(Self.self)

            let packetLength = try decoder.decode(UInt16.self)

            let charCount: UInt16
            if PACKET_VERSION >= 20100413 {
                charCount = (packetLength - 27) / CharInfo.size
            } else {
                charCount = (packetLength - 24) / CharInfo.size
            }

            if PACKET_VERSION >= 20100413 {
                totalSlotNum = try decoder.decode(UInt8.self)
                premiumStartSlot = try decoder.decode(UInt8.self)
                premiumEndSlot = try decoder.decode(UInt8.self)
            } else {
                totalSlotNum = 0
                premiumStartSlot = 0
                premiumEndSlot = 0
            }

            _ = try decoder.decode(String.self, length: 20)

            charList = []
            for _ in 0..<charCount {
                let charInfo = try decoder.decode(CharInfo.self)
                charList.append(charInfo)
            }
        }
    }
}
