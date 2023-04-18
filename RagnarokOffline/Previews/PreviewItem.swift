//
//  PreviewItem.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/8.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

enum PreviewItem {

    case url(URL)
    case grf(GRFDocument, GRFTreeNode)

    var url: URL {
        switch self {
        case .url(let url):
            return url
        case .grf(let grf, let node):
            return grf.url.appendingPathComponent(node.name.replacingOccurrences(of: "\\", with: "/"))
        }
    }

    var title: String {
        switch self {
        case .url(let url):
            return url.lastPathComponent
        case .grf(_, let node):
            let lastPathComponent = node.name.split(separator: "\\").last
            return String(lastPathComponent ?? "")
        }
    }

    var fileType: FileType {
        switch self {
        case .url(let url):
            return FileType(rawValue: url.pathExtension)
        case .grf(_, let node):
            let pathExtension = node.name.split(separator: "\\").last?.split(separator: ".").last
            return FileType(rawValue: String(pathExtension ?? ""))
        }
    }

    func data() throws -> Data {
        switch self {
        case .url(let url):
            return try Data(contentsOf: url)
        case .grf(_, let node):
            return node.contents ?? Data()
        }
    }
}
