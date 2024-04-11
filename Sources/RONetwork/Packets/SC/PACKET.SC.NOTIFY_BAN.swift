//
//  PACKET.SC.NOTIFY_BAN.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/27.
//

extension PACKET.SC {
    public struct NOTIFY_BAN: DecodablePacket {
        public static var packetType: UInt16 {
            0x81
        }

        public var errorCode: UInt8

        public var packetName: String {
            "PACKET_SC_NOTIFY_BAN"
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
