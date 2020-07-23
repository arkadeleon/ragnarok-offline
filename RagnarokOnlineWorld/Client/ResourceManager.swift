//
//  ResourceManager.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/7/10.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

class GRFNode {

    let pathComponent: String
    var entry: GRFEntry?
    private(set) var childNodes: [String: GRFNode] = [:]

    init(pathComponent: String) {
        self.pathComponent = pathComponent
    }

    func addChildNode(_ childNode: GRFNode) {
        childNodes[childNode.pathComponent] = childNode
    }
}

private class GRFDocumentWrapper {

    let url: URL
    let grf: GRFDocument
    let rootNode = GRFNode(pathComponent: "data")

    init(url: URL) throws {
        self.url = url

        let loader = DocumentLoader()
        grf = try loader.load(GRFDocument.self, from: url)

        for entry in grf.entries {
            insert(entry: entry)
        }
    }

    private func insert(entry: GRFEntry) {
        var currentNode = rootNode

        let pathComponents = entry.name.split(separator: "\\")
        for pathComponent in pathComponents {
            if let childNode = currentNode.childNodes[String(pathComponent)] {
                currentNode = childNode
            } else {
                let childNode = GRFNode(pathComponent: String(pathComponent))
                currentNode.addChildNode(childNode)
                currentNode = childNode
            }
        }

        currentNode.entry = entry
    }

    func nodes(withPath path: String) -> [GRFNode] {
        var currentNode = rootNode

        let pathComponents = path.split(separator: "\\")
        for pathComponent in pathComponents {
            guard let childNode = currentNode.childNodes[String(pathComponent)] else {
                return []
            }
            currentNode = childNode
        }

        return Array(currentNode.childNodes.values)
    }

    func entry(forPath path: String) -> GRFEntry? {
        var currentNode = rootNode

        let pathComponents = path.split(separator: "\\")

        for pathComponent in pathComponents {
            guard let childNode = currentNode.childNodes[String(pathComponent)] else {
                return nil
            }
            currentNode = childNode
        }

        return currentNode.entry
    }
}

class ResourceManager {

    static let `default` = ResourceManager()

    private var wrappers: [GRFDocumentWrapper] = []

    func preload() throws {
        let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let iniURL = url.appendingPathComponent("DATA.INI")

        if FileManager.default.fileExists(atPath: iniURL.path) {
            let loader = DocumentLoader()
            let ini = try loader.load(INIDocument.self, from: iniURL)
            for section in ini.sections where section.name == "Data" {
                for entry in section.entries {
                    let url = url.appendingPathComponent(entry.value)
                    let wrapper = try GRFDocumentWrapper(url: url)
                    wrappers.append(wrapper)
                }
            }
        } else if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil) {
            for element in enumerator {
                guard let url = element as? URL, url.pathExtension == "grf" else {
                    continue
                }
                let wrapper = try GRFDocumentWrapper(url: url.resolvingSymlinksInPath())
                wrappers.append(wrapper)
            }
        }
    }

    func nodes(withPath path: String, url: URL) throws -> [GRFNode] {
        guard let wrapper = wrappers.first(where: { $0.url == url }) else {
            throw DocumentError.invalidContents
        }

        return wrapper.nodes(withPath: path)
    }

    func contentsOfEntry(withName name: String) throws -> Data {
        for wrapper in wrappers {
            guard let entry = wrapper.entry(forPath: name) else {
                continue
            }
            let stream = try FileStream(url: wrapper.url)
            let data = try entry.data(from: stream)
            return data
        }
        throw DocumentError.invalidContents
    }

    func contentsOfEntry(withName name: String, url: URL) throws -> Data {
        guard let wrapper = wrappers.first(where: { $0.url == url }) else {
            throw DocumentError.invalidContents
        }

        guard let entry = wrapper.entry(forPath: name) else {
            throw DocumentError.invalidContents
        }

        let stream = try FileStream(url: wrapper.url)
        let data = try entry.data(from: stream)
        return data
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
