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
        let gatData = try await contentsOfResource(at: gatPath)
        let gat = try GAT(data: gatData)

        let gndPath = path.appendingPathExtension("gnd")
        let gndData = try await contentsOfResource(at: gndPath)
        let gnd = try GND(data: gndData)

        let rswPath = path.appendingPathExtension("rsw")
        let rswData = try await contentsOfResource(at: rswPath)
        let rsw = try RSW(data: rswData)

        let world = WorldResource(gat: gat, gnd: gnd, rsw: rsw)
        return world
    }
}
