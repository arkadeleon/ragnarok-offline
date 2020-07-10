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

    private(set) var grfs: [URL: GRFDocument] = [:]

    func preload() throws {
        let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let ini = try String(contentsOf: url.appendingPathComponent("DATA.INI"))
        let lines = ini.replacingOccurrences(of: "\r\n", with: "\n").split(separator: "\n")
        for line in lines {
            let pair = line.split(separator: "=")
            guard pair.count == 2 else {
                continue
            }
            let url = url.appendingPathComponent(String(pair[1]))
            let loader = DocumentLoader()
            let grf = try loader.load(GRFDocument.self, from: url)
            grfs[url] = grf
        }
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
