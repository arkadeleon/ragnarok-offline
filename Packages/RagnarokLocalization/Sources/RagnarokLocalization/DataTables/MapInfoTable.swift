//
//  MapInfoTable.swift
//  RagnarokLocalization
//
//  Created by Leon Li on 2024/5/27.
//

import Foundation

struct MapInfo: Decodable {
    var displayName: String
    var signMainTitle: String?
    var signSubTitle: String?
}

final public class MapInfoTable {
    let mapInfosByName: [String : MapInfo]

    public init(locale: Locale = .current) {
        guard let url = Bundle.module.url(forResource: "MapInfo", withExtension: "json", locale: locale) else {
            self.mapInfosByName = [:]
            return
        }

        do {
            let decoder = JSONDecoder()
            let data = try Data(contentsOf: url)
            self.mapInfosByName = try decoder.decode([String : MapInfo].self, from: data)
        } catch {
            self.mapInfosByName = [:]
        }
    }

    public func localizedMapName(forMapName mapName: String) -> String? {
        mapInfosByName[mapName]?.displayName
    }

    public func localizedMapSignMainTitle(forMapName mapName: String) -> String? {
        mapInfosByName[mapName]?.signMainTitle
    }

    public func localizedMapSignSubTitle(forMapName mapName: String) -> String? {
        mapInfosByName[mapName]?.signSubTitle
    }
}
