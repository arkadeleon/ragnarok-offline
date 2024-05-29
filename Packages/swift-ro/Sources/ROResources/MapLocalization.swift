//
//  MapLocalization.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/27.
//

import Foundation

public actor MapLocalization  {
    public static let shared = MapLocalization(locale: .current)

    let locale: Locale

    var mapNameTable: [String : String] = [:]
    var isMapNameTableLoaded = false

    init(locale: Locale) {
        self.locale = locale
    }

    public func localizedName(for mapName: String) -> String? {
        try? loadMapNameTableIfNeeded()

        let mapName = mapNameTable[mapName]
        return mapName
    }

    private func loadMapNameTableIfNeeded() throws {
        guard !isMapNameTableLoaded else {
            return
        }

        guard let url = Bundle.module.url(forResource: "mapnametable", withExtension: "txt", locale: locale) else {
            return
        }

        let data = try Data(contentsOf: url)

        guard let string = String(data: data, encoding: .isoLatin1) else {
            return
        }

        let lines = string.split(separator: "\r\n")
        let encoding = locale.language.preferredEncoding

        for line in lines {
            if line.trimmingCharacters(in: .whitespacesAndNewlines).starts(with: "//") {
                continue
            }

            let columns = line.split(separator: "#")
            if columns.count >= 2 {
                let mapName = String(columns[0]).replacingOccurrences(of: ".rsw", with: "")
                let mapDisplayName = String(columns[1]).trimmingCharacters(in: .whitespaces).data(using: .isoLatin1)?.string(using: encoding)
                mapNameTable[mapName] = mapDisplayName
            }
        }

        isMapNameTableLoaded = true
    }
}
