//
//  PACKET_ZC_FRIENDS_LIST.swift
//  NetworkPackets
//
//  Created by Leon Li on 2024/8/22.
//

import BinaryIO

/// See `clif_friendslist_send`
@available(*, deprecated, message: "Use generated struct instead.")
public struct _PACKET_ZC_FRIENDS_LIST: DecodablePacket {
    public static var packetType: Int16 {
        0x201
    }

    public var packetLength: Int16 {
        -1
    }

    public var friends: [_FriendInfo]

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        let packetLength = try decoder.decode(Int16.self)

        let friendCount = (packetLength - 4) / _FriendInfo.decodedLength

        friends = []
        for _ in 0..<friendCount {
            let friendInfo = try _FriendInfo(from: decoder)
            friends.append(friendInfo)
        }
    }
}

@available(*, deprecated, message: "Use generated struct instead.")
extension _PACKET_ZC_FRIENDS_LIST {
    public struct _FriendInfo: BinaryDecodable {
        public var accountID: UInt32
        public var charID: UInt32
        public var name: String

        public init(from decoder: BinaryDecoder) throws {
            accountID = try decoder.decode(UInt32.self)
            charID = try decoder.decode(UInt32.self)

            if !(PACKET_VERSION_MAIN_NUMBER >= 20180307 || PACKET_VERSION_RE_NUMBER >= 20180221 || PACKET_VERSION_ZERO_NUMBER >= 20180328) || PACKET_VERSION >= 20200902 {
                name = try decoder.decode(String.self, lengthOfBytes: 24)
            } else {
                name = ""
            }
        }
    }
}
