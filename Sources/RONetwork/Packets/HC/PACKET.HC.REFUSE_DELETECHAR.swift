//
//  PACKET.HC.REFUSE_DELETECHAR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

extension PACKET.HC {
    public struct REFUSE_DELETECHAR: DecodablePacket {
        public static var packetType: UInt16 {
            0x70
        }

        public var errorCode: UInt8

        public var packetName: String {
            "PACKET_HC_REFUSE_DELETECHAR"
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
