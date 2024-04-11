//
//  PACKET.CH.MAKE_CHAR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/6.
//

extension PACKET.CH {
    public struct MAKE_CHAR: EncodablePacket {
        public static var packetType: UInt16 {
            if PACKET_VERSION >= 20151001 {
                0xa39
            } else if PACKET_VERSION >= 20120307 {
                0x970
            } else {
                0x67
            }
        }

        public var name = ""
        public var str: UInt8 = 0
        public var agi: UInt8 = 0
        public var vit: UInt8 = 0
        public var int: UInt8 = 0
        public var dex: UInt8 = 0
        public var luk: UInt8 = 0
        public var charNum: UInt8 = 0
        public var headPal: UInt16 = 0
        public var head: UInt16 = 0
        public var job: UInt16 = 0
        public var sex: UInt8 = 0

        public var packetName: String {
            "PACKET_CH_MAKE_CHAR"
        }

        public var packetLength: UInt16 {
            if PACKET_VERSION >= 20151001 {
                2 + 24 + 1 + 2 + 2 + 2 + 1 + 1 + 1
            } else if PACKET_VERSION >= 20120307 {
                2 + 24 + 1 + 2 + 2
            } else {
                2 + 24 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 2 + 2
            }
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(packetType)

            try encoder.encode(name, length: 24)

            if PACKET_VERSION < 20120307 {
                try encoder.encode(str)
                try encoder.encode(agi)
                try encoder.encode(vit)
                try encoder.encode(int)
                try encoder.encode(dex)
                try encoder.encode(luk)
            }

            try encoder.encode(charNum)
            try encoder.encode(headPal)
            try encoder.encode(head)

            if PACKET_VERSION >= 20151001 {
                try encoder.encode(job)
                try encoder.encode(0 as UInt8)
                try encoder.encode(0 as UInt8)
                try encoder.encode(sex)
            }
        }
    }
}
