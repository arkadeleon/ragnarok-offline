//
//  PACKET.AC.REFUSE_LOGIN.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/6.
//

extension PACKET.AC {
    public struct REFUSE_LOGIN: DecodablePacket {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x006a = 0x006a
            case x083e = 0x083e
        }

        public static var packetType: PacketType {
            if PACKET_VERSION < 20120000 {
                .x006a
            } else {
                .x083e
            }
        }

        public var errorCode: UInt32 = 0
        public var blockDate = ""

        public var packetName: String {
            "PACKET_AC_REFUSE_LOGIN"
        }

        public var packetLength: UInt16 {
            switch packetType {
            case .x006a:
                2 + 1 + 20
            case .x083e:
                2 + 4 + 20
            }
        }

        public init(from decoder: BinaryDecoder) throws {
            let packetType = try decoder.decode(PacketType.self)

            switch packetType {
            case .x006a:
                errorCode = try UInt32(decoder.decode(UInt8.self))
            case .x083e:
                errorCode = try decoder.decode(UInt32.self)
            }

            blockDate = try decoder.decode(String.self, length: 20)
        }
    }
}
