//
//  PACKET.CH.MAKE_CHAR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/6.
//

extension PACKET.CH {
    public struct MAKE_CHAR: PacketProtocol {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x0067 = 0x0067
            case x0970 = 0x0970
            case x0a39 = 0x0a39
        }

        public let packetType: PacketType
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
            switch packetType {
            case .x0067:
                2 + 24 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 2 + 2
            case .x0970:
                2 + 24 + 1 + 2 + 2
            case .x0a39:
                2 + 24 + 1 + 2 + 2 + 2 + 1 + 1 + 1
            }
        }

        public init(packetVersion: PacketVersion) {
            if packetVersion.number < 20120307 {
                packetType = .x0067
            } else if packetVersion.number < 20151001 {
                packetType = .x0970
            } else {
                packetType = .x0a39
            }
        }

        public init(from decoder: BinaryDecoder) throws {
            packetType = try decoder.decode(PacketType.self)

            name = try decoder.decode(String.self, length: 24)

            if packetType == .x0067 {
                str = try decoder.decode(UInt8.self)
                agi = try decoder.decode(UInt8.self)
                vit = try decoder.decode(UInt8.self)
                int = try decoder.decode(UInt8.self)
                dex = try decoder.decode(UInt8.self)
                luk = try decoder.decode(UInt8.self)
            }

            charNum = try decoder.decode(UInt8.self)
            headPal = try decoder.decode(UInt16.self)
            head = try decoder.decode(UInt16.self)

            if packetType == .x0a39 {
                job = try decoder.decode(UInt16.self)
                _ = try decoder.decode(UInt8.self)
                _ = try decoder.decode(UInt8.self)
                sex = try decoder.decode(UInt8.self)
            }
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(packetType)

            try encoder.encode(name, length: 24)

            if packetType == .x0067 {
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

            if packetType == .x0a39 {
                try encoder.encode(job)
                try encoder.encode(0 as UInt8)
                try encoder.encode(0 as UInt8)
                try encoder.encode(sex)
            }
        }
    }
}
