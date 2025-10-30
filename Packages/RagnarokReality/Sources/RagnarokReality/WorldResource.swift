//
//  WorldResource.swift
//  RagnarokReality
//
//  Created by Leon Li on 2025/2/26.
//

import RagnarokFileFormats
import RagnarokResources

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

    // The map name should contain rsw suffix.
    public func world(mapName: String) async throws -> WorldResource {
        let resourceNameTable = await resourceNameTable()

        let rswResourceName = resourceNameTable.resourceName(forAlias: mapName) ?? mapName
        let rswPath = ResourcePath(components: ["data", rswResourceName])
        let rswData = try await contentsOfResource(at: rswPath)
        let rsw = try RSW(data: rswData)

        let gatResourceName = resourceNameTable.resourceName(forAlias: rsw.files.gat) ?? rsw.files.gat
        let gatPath = ResourcePath(components: ["data", gatResourceName])
        async let gatData = contentsOfResource(at: gatPath)

        let gndResourceName = resourceNameTable.resourceName(forAlias: rsw.files.gnd) ?? rsw.files.gnd
        let gndPath = ResourcePath(components: ["data", gndResourceName])
        async let gndData = contentsOfResource(at: gndPath)

        let gat = try await GAT(data: gatData)
        let gnd = try await GND(data: gndData)

        let world = WorldResource(gat: gat, gnd: gnd, rsw: rsw)
        return world
    }
}
