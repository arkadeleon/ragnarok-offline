//
//  PACKET.AC.ACCEPT_LOGIN.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/6.
//

extension PACKET.AC {
    public struct ACCEPT_LOGIN: PacketProtocol {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x0069 = 0x0069
            case x0ac4 = 0x0ac4

            public init(packetVersion: PacketVersion) {
                if packetVersion.number < 20170315 {
                    self = .x0069
                } else {
                    self = .x0ac4
                }
            }
        }

        public let packetType: PacketType
        public var authCode: UInt32 = 0
        public var aid: UInt32 = 0
        public var userLevel: UInt32 = 0
        public var lastLoginIP: UInt32 = 0
        public var lastLoginTime = ""
        public var sex: UInt8 = 0
        public var token = [UInt8](repeating: 0, count: 17)
        public var serverList: [ServerInfo] = []

        public var packetName: String {
            "PACKET_AC_ACCEPT_LOGIN"
        }

        public var packetLength: UInt16 {
            2 + 2 + 4 + 4 + 4 + 4 + 26 + 1 + ServerInfo.size(for: packetType) * UInt16(serverList.count)
        }

        public init(packetVersion: PacketVersion) {
            packetType = PacketType(packetVersion: packetVersion)
        }

        public init(from decoder: BinaryDecoder) throws {
            packetType = try decoder.decode(PacketType.self)

            let packetLength = try decoder.decode(UInt16.self)
            let serverCount = (packetLength - 2 - 2 - 4 - 4 - 4 - 4 - 26 - 1) / ServerInfo.size(for: packetType)

            authCode = try decoder.decode(UInt32.self)
            aid = try decoder.decode(UInt32.self)
            userLevel = try decoder.decode(UInt32.self)
            lastLoginIP = try decoder.decode(UInt32.self)
            lastLoginTime = try decoder.decode(String.self, length: 26)
            sex = try decoder.decode(UInt8.self)

            if packetType == .x0ac4 {
                token = try decoder.decode([UInt8].self, length: 17)
            }

            for _ in 0..<serverCount {
                let serverInfo = try decoder.decode(ServerInfo.self)
                serverList.append(serverInfo)
            }
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(packetType)

            try encoder.encode(packetLength)
            try encoder.encode(authCode)
            try encoder.encode(aid)
            try encoder.encode(userLevel)
            try encoder.encode(lastLoginIP)
            try encoder.encode(lastLoginTime, length: 26)
            try encoder.encode(sex)

            if packetType == .x0ac4 {
                try encoder.encode(token)
            }

            for serverInfo in serverList {
                try encoder.encode(serverInfo)
            }
        }
    }
}

extension PACKET.AC.ACCEPT_LOGIN {
    public struct ServerInfo: BinaryDecodable, BinaryEncodable {
        public let packetType: PacketType
        public var ip: UInt32 = 0
        public var port: UInt16 = 0
        public var name = ""
        public var userCount: UInt16 = 0
        public var state: UInt16 = 0
        public var property: UInt16 = 0

        public static func size(for packetType: PacketType) -> UInt16 {
            switch packetType {
            case .x0069: 32
            case .x0ac4: 32 + 128
            }
        }

        public init(packetType: PacketType) {
            self.packetType = packetType
        }

        public init(from decoder: BinaryDecoder) throws {
            let packetVersion = decoder.userInfo[.packetVersionKey] as! PacketVersion

            packetType = PacketType(packetVersion: packetVersion)

            ip = try decoder.decode(UInt32.self)
            port = try decoder.decode(UInt16.self)
            name = try decoder.decode(String.self, length: 20)
            userCount = try decoder.decode(UInt16.self)
            state = try decoder.decode(UInt16.self)
            property = try decoder.decode(UInt16.self)

            if packetType == .x0ac4 {
                _ = try decoder.decode([UInt8].self, length: 128)
            }
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(ip)
            try encoder.encode(port)
            try encoder.encode(name, length: 20)
            try encoder.encode(userCount)
            try encoder.encode(state)
            try encoder.encode(property)

            if packetType == .x0ac4 {
                try encoder.encode([UInt8](repeating: 0, count: 128))
            }
        }
    }
}
