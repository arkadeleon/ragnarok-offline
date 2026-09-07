//
//  WarpList.swift
//  RagnarokModels
//
//  Created by Leon Li on 2026/9/7.
//

import RagnarokPackets

public struct WarpList {
    public let skillID: Int
    public let mapNames: [String]

    public init(skillID: Int, mapNames: [String]) {
        self.skillID = skillID
        self.mapNames = mapNames
    }

    public init(from packet: PACKET_ZC_WARPLIST) {
        self.skillID = Int(packet.skillId)
        self.mapNames = packet.maps.map(\.map).filter({ !$0.isEmpty })
    }
}
