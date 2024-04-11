//
//  PACKET.HC.ACCEPT_MAKECHAR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

extension PACKET.HC {
    public struct ACCEPT_MAKECHAR: DecodablePacket {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x006d = 0x006d
            case x0b6f = 0x0b6f
        }

        public static var packetType: PacketType {
            if PACKET_VERSION_MAIN_NUMBER >= 20201007 || PACKET_VERSION_RE_NUMBER >= 20211103 {
                .x0b6f
            } else {
                .x006d
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
            let packetType = try decoder.decode(PacketType.self)
            charInfo = try decoder.decode(CharInfo.self)
        }
    }
}
