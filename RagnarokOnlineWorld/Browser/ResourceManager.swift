//
//  ResourceManager.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/7/10.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

class ResourceManager {

    private struct GRFDocumentWrapper {
        var url: URL
        var grf: GRFDocument
    }

    static let `default` = ResourceManager()

    private var wrappers: [GRFDocumentWrapper] = []

    func preload() throws {
        let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let iniURL = url.appendingPathComponent("DATA.INI")
        let loader = DocumentLoader()
        let ini = try loader.load(INIDocument.self, from: iniURL)
        for section in ini.sections where section.name == "Data" {
            for entry in section.entries {
                let grfURL = url.appendingPathComponent(entry.value)
                let grf = try loader.load(GRFDocument.self, from: grfURL)
                let wrapper = GRFDocumentWrapper(url: grfURL, grf: grf)
                wrappers.append(wrapper)
            }
        }
    }

    func grf(for url: URL) -> GRFDocument? {
        wrappers.first { $0.url == url }?.grf
    }

    func contentsOfEntry(withName name: String) throws -> Data {
        for wrapper in wrappers {
            guard let entry = wrapper.grf.entries.first(where: { $0.name.lowercased() == name.lowercased() }) else {
                continue
            }
            let stream = try FileStream(url: wrapper.url)
            let contents = try wrapper.grf.contents(of: entry, from: stream)
            return contents
        }
        throw DocumentError.invalidContents
    }

    func contentsOfEntry(withName name: String, url: URL) throws -> Data {
        guard let wrapper = wrappers.first(where: { $0.url == url }) else {
            throw DocumentError.invalidContents
        }

        guard let entry = wrapper.grf.entries.first(where: { $0.name.lowercased() == name.lowercased() }) else {
            throw DocumentError.invalidContents
        }

        let stream = try FileStream(url: wrapper.url)
        let contents = try wrapper.grf.contents(of: entry, from: stream)
        return contents
    }

    func contentsOfEntry(withName name: String, preferredURL url: URL) throws -> Data {
        do {
            let contents = try contentsOfEntry(withName: name, url: url)
            return contents
        } catch {
            return try contentsOfEntry(withName: name)
        }
    }
}
