//
//  PACKET.HC.ACCEPT_DELETECHAR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

extension PACKET.HC {
    public struct ACCEPT_DELETECHAR: DecodablePacket {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x006f = 0x006f
        }

        public static var packetType: PacketType {
            .x006f
        }

        public var packetName: String {
            "PACKET_HC_ACCEPT_DELETECHAR"
        }

        public var packetLength: UInt16 {
            2
        }

        public init(from decoder: BinaryDecoder) throws {
            let packetType = try decoder.decode(PacketType.self)
        }
    }
}
