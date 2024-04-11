//
//  PACKET.HC.REFUSE_ENTER.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

extension PACKET.HC {
    public struct REFUSE_ENTER: DecodablePacket {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x006c = 0x006c
        }

        public static var packetType: PacketType {
            .x006c
        }

        public var errorCode: UInt8

        public var packetName: String {
            "PACKET_HC_REFUSE_ENTER"
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
