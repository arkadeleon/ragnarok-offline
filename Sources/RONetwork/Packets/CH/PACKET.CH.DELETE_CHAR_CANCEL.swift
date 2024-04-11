//
//  PACKET.CH.DELETE_CHAR_CANCEL.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

extension PACKET.CH {
    public struct DELETE_CHAR_CANCEL: EncodablePacket {
        public static var packetType: UInt16 {
            0x82b
        }

        public var gid: UInt32 = 0

        public var packetName: String {
            "PACKET_CH_DELETE_CHAR_CANCEL"
        }

        public var packetLength: UInt16 {
            2 + 4
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(packetType)
            try encoder.encode(gid)
        }
    }
}
