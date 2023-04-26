//
//  DocumentWrapper.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/18.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import UIKit

enum DocumentWrapper {

    case url(URL)
    case grf(GRFDocument)
    case grfNode(GRFDocument, GRFTreeNode)

    var isDirectory: Bool {
        switch self {
        case .url(let url):
            let values = try? url.resourceValues(forKeys: [.isDirectoryKey])
            return values?.isDirectory == true
        case .grf:
            return false
        case .grfNode(_, let node):
            return node.isDirectory
        }
    }

    var isArchive: Bool {
        switch self {
        case .url:
            return false
        case .grf:
            return true
        case .grfNode:
            return false
        }
    }

    var contentType: FileType? {
        if isDirectory {
            return nil
        }

        switch self {
        case .url(let url):
            let fileType = FileType(rawValue: url.pathExtension)
            return fileType
        case .grf:
            return nil
        case .grfNode(_, let node):
            let pathExtension = node.name.split(separator: "\\").last?.split(separator: ".").last
            let fileType = FileType(rawValue: String(pathExtension ?? ""))
            return fileType
        }
    }

    var url: URL {
        switch self {
        case .url(let url):
            return url
        case .grf(let grf):
            return grf.url
        case .grfNode(let grf, let node):
            let name = node.name.replacing("\\", with: "/")
            return grf.url.appendingPathComponent(name)
        }
    }

    var name: String {
        switch self {
        case .url(let url):
            return url.lastPathComponent
        case .grf(let grf):
            return grf.url.lastPathComponent
        case .grfNode(_, let node):
            let lastPathComponent = node.name.split(separator: "\\").last
            return String(lastPathComponent ?? "")
        }
    }

    func contents() -> Data? {
        switch self {
        case .url(let url) where !isDirectory:
            return try? Data(contentsOf: url)
        case .grf:
            return nil
        case .grfNode(_, let node) where !isDirectory:
            return node.contents
        default:
            return nil
        }
    }

    func documentWrappers() -> [DocumentWrapper] {
        var documentWrappers: [DocumentWrapper] = []

        switch self {
        case .url(let url) where isDirectory:
            guard let urls = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []) else {
                break
            }
            documentWrappers = urls.map({ $0.resolvingSymlinksInPath() }).map { url -> DocumentWrapper in
                switch url.pathExtension.lowercased() {
                case "grf":
                    let grf = GRFDocument(fileURL: url)
                    return .grf(grf)
                default:
                    return .url(url)
                }
            }
        case .grf(let grf):
            guard let node = grf.node(atPath: "data\\") else {
                break
            }
            let documentWrapper = DocumentWrapper.grfNode(grf, node)
            documentWrappers = documentWrapper.documentWrappers()
        case .grfNode(let grf, let node) where isDirectory:
            documentWrappers = node.children.map { node in
                DocumentWrapper.grfNode(grf, node)
            }
        default:
            break
        }

        documentWrappers.sort { document1, document2 in
            if document1.isDirectory == document2.isDirectory {
                return document1.name.lowercased() < document2.name.lowercased()
            } else {
                let rank1 = document1.isDirectory ? 0 : 1
                let rank2 = document2.isDirectory ? 0 : 1
                return rank1 < rank2
            }
        }

        return documentWrappers
    }
}

extension DocumentWrapper: Identifiable {
    var id: URL {
        url
    }
}
