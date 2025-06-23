//
//  WorldResource.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/26.
//

import ROFileFormats
import ROResources

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

extension ResourceManager {
    public func world(at path: ResourcePath) async throws -> WorldResource {
        let gatPath = path.appendingPathExtension("gat")
        async let gatData = contentsOfResource(at: gatPath)

        let gndPath = path.appendingPathExtension("gnd")
        async let gndData = contentsOfResource(at: gndPath)

        let rswPath = path.appendingPathExtension("rsw")
        async let rswData = contentsOfResource(at: rswPath)

        let gat = try GAT(data: await gatData)
        let gnd = try GND(data: await gndData)
        let rsw = try RSW(data: await rswData)

        let world = WorldResource(gat: gat, gnd: gnd, rsw: rsw)
        return world
    }
}
