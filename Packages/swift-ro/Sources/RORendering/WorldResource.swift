//
//  WorldResource.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/26.
//

import ROFileFormats

final public class WorldResource: Sendable {
    public let gat: GAT
    public let gnd: GND
    public let rsw: RSW

    public init(gat: GAT, gnd: GND, rsw: RSW) {
        self.gat = gat
        self.gnd = gnd
        self.rsw = rsw
    }
}
