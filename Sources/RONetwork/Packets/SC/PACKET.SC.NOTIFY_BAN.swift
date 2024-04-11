//
//  PACKET.SC.NOTIFY_BAN.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/27.
//

extension PACKET.SC {
    public struct NOTIFY_BAN: DecodablePacket {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x0081 = 0x0081
        }

        public static var packetType: PacketType {
            .x0081
        }

        public var errorCode: UInt8

        public var packetName: String {
            "PACKET_SC_NOTIFY_BAN"
        }

        public var packetLength: UInt16 {
            2 + 1
        }

        public init(from decoder: BinaryDecoder) throws {
            let packetType = try decoder.decode(PacketType.self)
            errorCode = try decoder.decode(UInt8.self)
        }
    }
}
