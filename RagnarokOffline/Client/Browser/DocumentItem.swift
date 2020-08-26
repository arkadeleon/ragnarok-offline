//
//  DocumentItem.swift
//  RagnarokOffline
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

    var title: String {
        switch self {
        case .directory(let url):
            return url.lastPathComponent
        case .grf(let tree):
            return tree.url.lastPathComponent
        case .entryGroup(let tree, let path):
            return tree.url.appendingPathComponent(path.replacingOccurrences(of: "\\", with: "/")).lastPathComponent
        case .previewItem(let previewItem):
            return previewItem.title
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
                        return .previewItem(url)
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
                    let previewItem = Entry(tree: tree, name: entry.name)
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
        lhs.title == rhs.title
    }

    static func < (lhs: DocumentItem, rhs: DocumentItem) -> Bool {
        if lhs.rank == rhs.rank {
            return lhs.title.lowercased() < rhs.title.lowercased()
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
