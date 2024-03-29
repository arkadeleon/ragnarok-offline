//
//  ResourceBundle.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/9/2.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

class ResourceBundle {

    let url: URL
    let priority: Int

    private let entries: [String: GRFEntry]

    init?(url: URL, priority: Int) {
        guard url.pathExtension.lowercased() == "grf" else {
            return nil
        }

        self.url = url
        self.priority = priority

        guard let grf = try? GRF(url: url) else {
            return nil
        }

        var entries: [String: GRF.Entry] = [:]
        for entry in grf.table.entries {
            entries[entry.name] = entry
        }
        self.entries = entries
    }

    func contents(forResource name: String) -> Data? {
        guard let entry = entries[name] else {
            return nil
        }

        do {
            let stream = try FileStream(url: url)
            let data = try entry.data(from: stream)
            return data
        } catch {
            return nil
        }
    }
}
