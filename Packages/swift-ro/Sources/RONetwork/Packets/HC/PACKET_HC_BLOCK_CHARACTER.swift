//
//  PACKET_HC_BLOCK_CHARACTER.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/12.
//

/// See `chclif_block_character`
public struct PACKET_HC_BLOCK_CHARACTER: DecodablePacket {
    public static var packetType: Int16 {
        0x20d
    }

    public var packetLength: Int16 {
        4 + 24 * Int16(chars.count)
    }

    public var chars: [CharBlockInfo]

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        let packetLength = try decoder.decode(Int16.self)

        let characterCount = (packetLength - 4) / 24

        chars = []
        for _ in 0..<characterCount {
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
