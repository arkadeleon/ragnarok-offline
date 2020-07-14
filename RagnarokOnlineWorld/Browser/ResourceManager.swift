//
//  ResourceManager.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/7/10.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

class ResourceManager {

    static let `default` = ResourceManager()

    private var grfs: [(URL, GRFDocument)] = []

    func preload() throws {
        let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let iniURL = url.appendingPathComponent("DATA.INI")
        let loader = DocumentLoader()
        let ini = try loader.load(INIDocument.self, from: iniURL)
        for section in ini.sections where section.name == "Data" {
            for entry in section.entries {
                let grfURL = url.appendingPathComponent(entry.value)
                let grf = try loader.load(GRFDocument.self, from: grfURL)
                grfs.append((grfURL, grf))
            }
        }
    }

    func grf(for url: URL) -> GRFDocument? {
        grfs.first { $0.0 == url }?.1
    }

    func contentsOfEntry(withName name: String) throws -> Data {
        for (url, grf) in grfs {
            guard let entry = grf.entry(forName: name) else {
                continue
            }
            let stream = try FileStream(url: url)
            let contents = try grf.contents(of: entry, from: stream)
            return contents
        }
        throw DocumentError.invalidContents
    }
}
