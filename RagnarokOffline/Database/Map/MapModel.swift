//
//  MapModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/7.
//

import CoreGraphics
import Observation
import RagnarokDatabase
import RagnarokResources

@Observable
@dynamicMemberLookup
final class MapModel {
    private let mode: DatabaseMode
    private let map: Map

    var localizedName: String?
    var image: CGImage?

    var displayName: String {
        localizedName ?? map.name
    }

    init(mode: DatabaseMode, map: Map) {
        self.mode = mode
        self.map = map
    }

    subscript<Value>(dynamicMember keyPath: KeyPath<Map, Value>) -> Value {
        map[keyPath: keyPath]
    }

    @MainActor
    func fetchLocalizedName() async {
        let mapNameTable = await ResourceManager.shared.mapNameTable(for: .current)
        localizedName = mapNameTable.localizedMapName(forMapName: map.name)
    }

    @MainActor
    func fetchImage() async {
        if image == nil {
            let path = ResourcePath.generateMapImagePath(mapName: map.name)
            image = try? await ResourceManager.shared.image(at: path, removesMagentaPixels: true)
        }
    }
}

extension MapModel: Equatable {
    static func == (lhs: MapModel, rhs: MapModel) -> Bool {
        lhs.map.name == rhs.map.name
    }
}

extension MapModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(map.name)
    }
}

extension MapModel: Identifiable {
    var id: String {
        map.name
    }
}
