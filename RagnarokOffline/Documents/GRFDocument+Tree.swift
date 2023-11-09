//
//  GRFDocument+Tree.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/8/17.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

class GRFTreeNode {

    let pathComponent: String

    fileprivate(set) var entry: GRFEntry?
    private(set) var children: [String: GRFTreeNode] = [:]

    init(pathComponent: String) {
        self.pathComponent = pathComponent
    }

    fileprivate func add(child: GRFTreeNode) {
        children[child.pathComponent] = child
    }
}

class GRFTree {

    let url: URL

    private let root = GRFTreeNode(pathComponent: "data")
    private var isLoaded = false

    init(url: URL) {
        self.url = url
    }

    private func loadIfNeeded() throws {
        guard isLoaded == false else {
            return
        }

        let grf = try GRFDocument(url: url)

        for entry in grf.entries {
            insert(entry: entry)
        }

        isLoaded = true
    }

    private func insert(entry: GRFEntry) {
        var currentNode = root

        let pathComponents = entry.name.split(separator: "\\")
        for pathComponent in pathComponents {
            if let childNode = currentNode.children[String(pathComponent)] {
                currentNode = childNode
            } else {
                let childNode = GRFTreeNode(pathComponent: String(pathComponent))
                currentNode.add(child: childNode)
                currentNode = childNode
            }
        }

        currentNode.entry = entry
    }

    func nodes(withPath path: String) -> [GRFTreeNode] {
        try? loadIfNeeded()

        var currentNode = root

        let pathComponents = path.split(separator: "\\")
        for pathComponent in pathComponents {
            guard let childNode = currentNode.children[String(pathComponent)] else {
                return []
            }
            currentNode = childNode
        }

        return Array(currentNode.children.values)
    }

    func contentsOfEntry(withName name: String) throws -> Data {
        try? loadIfNeeded()

        var currentNode = root

        let pathComponents = name.split(separator: "\\")

        for pathComponent in pathComponents {
            guard let childNode = currentNode.children[String(pathComponent)] else {
                throw DocumentError.invalidSource
            }
            currentNode = childNode
        }

        guard let entry = currentNode.entry else {
            throw DocumentError.invalidSource
        }

        let stream = try FileStream(url: url)
        let reader = BinaryReader(stream: stream)

        defer {
            reader.close()
        }

        let data = try entry.data(from: reader)

        return data
    }
}
