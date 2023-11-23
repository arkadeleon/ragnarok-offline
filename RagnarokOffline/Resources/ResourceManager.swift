//
//  ResourceManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/10.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

class ResourceManager {

    static let `default` = ResourceManager()

    private var grfs: [GRFWrapper] = []

    func load() throws {
        let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let iniURL = url.appendingPathComponent("DATA.INI")

        if FileManager.default.fileExists(atPath: iniURL.path) {
            let ini = try INI(url: iniURL)
            for section in ini.sections where section.name == "Data" {
                for entry in section.entries {
                    let url = url.appendingPathComponent(entry.value)
                    let grf = GRFWrapper(url: url)
                    grfs.append(grf)
                }
            }
        } else if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil) {
            for element in enumerator {
                guard let url = element as? URL, url.pathExtension == "grf" else {
                    continue
                }
                let grf = GRFWrapper(url: url.resolvingSymlinksInPath())
                grfs.append(grf)
            }
        }
    }

    func contentsOfEntry(withName name: String) throws -> Data {
        for grf in grfs {
            let data = try grf.contentsOfEntry(withName: name)
            return data
        }
        throw DocumentError.invalidContents
    }
}
