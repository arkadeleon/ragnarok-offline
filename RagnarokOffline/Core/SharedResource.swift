//
//  SharedResource.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/5/8.
//

import ROResources

extension ResourceManager {
    static let shared = ResourceManager(baseURL: .documentsDirectory)
}

extension ScriptManager {
    static let shared = ScriptManager(locale: .current, resourceManager: .shared)
}

extension MapMP3NameTable {
    static let shared = MapMP3NameTable(resourceManager: .shared)
}

extension ResourcePathProvider {
    func mapBGMPath(mapName: String) async -> ResourcePath? {
        guard let mp3Name = await MapMP3NameTable.shared.mapMP3Name(forMapName: mapName) else {
            return nil
        }

        return ["BGM", mp3Name]
    }
}
