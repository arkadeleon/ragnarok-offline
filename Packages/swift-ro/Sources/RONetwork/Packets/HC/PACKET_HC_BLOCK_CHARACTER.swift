//
//  PACKET_HC_BLOCK_CHARACTER.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/12.
//

import ROCore

/// See `chclif_block_character`
public struct PACKET_HC_BLOCK_CHARACTER: DecodablePacket {
    public static var packetType: Int16 {
        0x20d
    }

    public var packetLength: Int16 {
        -1
    }

    public var chars: [CharBlockInfo]

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        let packetLength = try decoder.decode(Int16.self)

        let charCount = (packetLength - 4) / CharBlockInfo.decodedLength

        chars = []
        for _ in 0..<charCount {
            let charBlockInfo = try CharBlockInfo(from: decoder)
            chars.append(charBlockInfo)
        }
    }
}

extension PACKET_HC_BLOCK_CHARACTER {
    public struct CharBlockInfo: BinaryDecodable {
        public var charID: UInt32
        public var szExpireDate: String

        public init(from decoder: BinaryDecoder) throws {
            charID = try decoder.decode(UInt32.self)
            szExpireDate = try decoder.decode(String.self, length: 20)
        }
    }
}
