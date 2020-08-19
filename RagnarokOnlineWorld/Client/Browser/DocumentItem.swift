//
//  DocumentItem.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/7.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

enum DocumentItem {

    case directory(URL)
    case grf(GRFTree)
    case entryGroup(GRFTree, String)
    case previewItem(PreviewItem)
}

extension DocumentItem {

    var url: URL {
        switch self {
        case .directory(let url):
            return url
        case .grf(let tree):
            return tree.url
        case .entryGroup(let tree, let path):
            return tree.url.appendingPathComponent(path.replacingOccurrences(of: "\\", with: "/"))
        case .previewItem(let previewItem):
            switch previewItem {
            case .url(let url):
                return url
            case .entry(let tree, let name):
                return tree.url.appendingPathComponent(name.replacingOccurrences(of: "\\", with: "/"))
            }
        }
    }

    var icon: UIImage? {
        switch self {
        case .directory:
            return UIImage(systemName: "folder")
        case .grf:
            return UIImage(systemName: "doc.zipper")
        case .entryGroup:
            return UIImage(systemName: "folder")
        case .previewItem(let previewItem):
            return previewItem.placeholder
        }
    }

    var children: [DocumentItem]? {
        switch self {
        case .directory(let url):
            guard let urls = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []) else {
                return nil
            }
            let children = urls
                .map{ url -> URL in
                    url.resolvingSymlinksInPath()
                }
                .map { url -> DocumentItem in
                    if url.hasDirectoryPath {
                        return .directory(url)
                    }
                    switch url.pathExtension.lowercased() {
                    case "grf":
                        let tree = GRFTree(url: url)
                        return .grf(tree)
                    default:
                        let previewItem: PreviewItem = .url(url)
                        return .previewItem(previewItem)
                    }
                }
            return children
        case .grf(let tree):
            return DocumentItem.entryGroup(tree, "data\\").children
        case .entryGroup(let tree, let path):
            var children: [DocumentItem] = []
            let nodes = tree.nodes(withPath: path)
            for node in nodes {
                if let entry = node.entry {
                    let previewItem: PreviewItem = .entry(tree, entry.name)
                    let child: DocumentItem = .previewItem(previewItem)
                    children.append(child)
                } else {
                    let path = "\(path)\(node.pathComponent)\\"
                    let child: DocumentItem = .entryGroup(tree, path)
                    children.append(child)
                }
            }
            return children
        case .previewItem:
            return nil
        }
    }
}

extension DocumentItem: Equatable, Comparable {
    static func == (lhs: DocumentItem, rhs: DocumentItem) -> Bool {
        lhs.url == rhs.url
    }

    static func < (lhs: DocumentItem, rhs: DocumentItem) -> Bool {
        if lhs.rank == rhs.rank {
            return lhs.url.path.lowercased() < rhs.url.path.lowercased()
        } else {
            return lhs.rank < rhs.rank
        }
    }

    var rank: Int {
        switch self {
        case .directory,
             .entryGroup:
            return 0
        default:
            return 1
        }
    }
}
