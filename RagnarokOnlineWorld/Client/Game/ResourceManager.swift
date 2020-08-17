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

    private var trees: [GRFTree] = []

    func load() throws {
        let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let iniURL = url.appendingPathComponent("DATA.INI")

        if FileManager.default.fileExists(atPath: iniURL.path) {
            let loader = DocumentLoader()
            let ini = try loader.load(INIDocument.self, from: iniURL)
            for section in ini.sections where section.name == "Data" {
                for entry in section.entries {
                    let url = url.appendingPathComponent(entry.value)
                    let tree = GRFTree(url: url)
                    trees.append(tree)
                }
            }
        } else if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil) {
            for element in enumerator {
                guard let url = element as? URL, url.pathExtension == "grf" else {
                    continue
                }
                let tree = GRFTree(url: url.resolvingSymlinksInPath())
                trees.append(tree)
            }
        }
    }

    func contentsOfEntry(withName name: String) throws -> Data {
        for tree in trees {
            let data = try tree.contentsOfEntry(withName: name)
            return data
        }
        throw DocumentError.invalidContents
    }
}
