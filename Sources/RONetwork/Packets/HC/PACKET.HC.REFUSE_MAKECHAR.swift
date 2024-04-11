//
//  PACKET.HC.REFUSE_MAKECHAR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

extension PACKET.HC {
    public struct REFUSE_MAKECHAR: DecodablePacket {
        public static var packetType: UInt16 {
            0x6e
        }

        public var errorCode: UInt8

        public var packetName: String {
            "PACKET_HC_REFUSE_MAKECHAR"
        }

        public var packetLength: UInt16 {
            2 + 1
        }

        public init(from decoder: BinaryDecoder) throws {
            try decoder.decodePacketType(Self.self)
            errorCode = try decoder.decode(UInt8.self)
        }
    }
}
