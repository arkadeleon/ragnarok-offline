//
//  PACKET.HC.DELETE_CHAR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

extension PACKET.HC {
    public struct DELETE_CHAR: DecodablePacket {
        public static var packetType: UInt16 {
            0x82a
        }

        public var aid: UInt32
        public var result: UInt32

        public var packetName: String {
            "PACKET_HC_DELETE_CHAR"
        }

        public var packetLength: UInt16 {
            2 + 4 + 4
        }

        public init(from decoder: BinaryDecoder) throws {
            try decoder.decodePacketType(Self.self)
            aid = try decoder.decode(UInt32.self)
            result = try decoder.decode(UInt32.self)
        }
    }
}
