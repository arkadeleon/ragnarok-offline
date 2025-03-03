//
//  MusicResource.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/3.
//

import ROResources

extension ResourcePath {
    public init?(mapBGMPathWithMapName mapName: String) async {
        guard let mp3Name = await MapMP3NameTable.current.mapMP3Name(forMapName: mapName) else {
            return nil
        }

        self = ["BGM", mp3Name]
    }
}
