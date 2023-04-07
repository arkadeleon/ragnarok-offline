//
//  PreviewItem.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/8.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

protocol PreviewItem {

    var url: URL { get }
    var title: String { get }
    var fileType: FileType { get }
    func data() throws -> Data
}

extension URL: PreviewItem {

    var url: URL {
        self
    }

    var title: String {
        lastPathComponent
    }

    var fileType: FileType {
        FileType(rawValue: pathExtension)
    }

    func data() throws -> Data {
        try Data(contentsOf: self)
    }
}

struct Entry: PreviewItem {

    var tree: GRFTree
    var name: String

    var url: URL {
        tree.url.appendingPathComponent(name.replacingOccurrences(of: "\\", with: "/"))
    }

    var title: String {
        let lastPathComponent = name.split(separator: "\\").last
        return String(lastPathComponent ?? "")
    }

    var fileType: FileType {
        let pathExtension = name.split(separator: "\\").last?.split(separator: ".").last
        return FileType(rawValue: String(pathExtension ?? ""))
    }

    func data() throws -> Data {
        try tree.contentsOfEntry(withName: name)
    }
}
