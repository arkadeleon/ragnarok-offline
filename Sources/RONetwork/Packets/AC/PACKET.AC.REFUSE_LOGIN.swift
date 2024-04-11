//
//  PACKET.AC.REFUSE_LOGIN.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/6.
//

extension PACKET.AC {
    public struct REFUSE_LOGIN: DecodablePacket {
        public static var packetType: UInt16 {
            if PACKET_VERSION >= 20120000 {
                0x83e
            } else {
                0x6a
            }
        }

        public var errorCode: UInt32 = 0
        public var blockDate = ""

        public var packetName: String {
            "PACKET_AC_REFUSE_LOGIN"
        }

        public var packetLength: UInt16 {
            if PACKET_VERSION >= 20120000 {
                2 + 4 + 20
            } else {
                2 + 1 + 20
            }
        }

        public init(from decoder: BinaryDecoder) throws {
            try decoder.decodePacketType(Self.self)

            if PACKET_VERSION >= 20120000 {
                errorCode = try decoder.decode(UInt32.self)
            } else {
                errorCode = try UInt32(decoder.decode(UInt8.self))
            }

            blockDate = try decoder.decode(String.self, length: 20)
        }
    }
}
