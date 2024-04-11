//
//  PACKET.HC.ACCEPT_MAKECHAR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

extension PACKET.HC {
    public struct ACCEPT_MAKECHAR: DecodablePacket {
        public static var packetType: UInt16 {
            if PACKET_VERSION_MAIN_NUMBER >= 20201007 || PACKET_VERSION_RE_NUMBER >= 20211103 {
                0xb6f
            } else {
                0x6d
            }
        }

        public var charInfo: CharInfo

        public var packetName: String {
            "PACKET_HC_ACCEPT_MAKECHAR"
        }

        public var packetLength: UInt16 {
            2 + CharInfo.size
        }

        public init(from decoder: BinaryDecoder) throws {
            try decoder.decodePacketType(Self.self)
            charInfo = try decoder.decode(CharInfo.self)
        }
    }
}
