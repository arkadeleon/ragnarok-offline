//
//  DocumentItem.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/7.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

enum DocumentItem: Identifiable {

    case directory(URL)
    case grf(GRFDocument)
    case grfDirectory(GRFDocument, String)
    case previewItem(PreviewItem)

    var id: URL {
        switch self {
        case .directory(let url):
            return url
        case .grf(let grf):
            return grf.url
        case .grfDirectory(let grf, let path):
            return grf.url.appendingPathComponent(path.replacingOccurrences(of: "\\", with: "/"))
        case .previewItem(let previewItem):
            return previewItem.url
        }
    }
}

extension DocumentItem {

    var title: String {
        switch self {
        case .directory(let url):
            return url.lastPathComponent
        case .grf(let grf):
            return grf.url.lastPathComponent
        case .grfDirectory(let grf, let path):
            return grf.url.appendingPathComponent(path.replacingOccurrences(of: "\\", with: "/")).lastPathComponent
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
        case .grfDirectory:
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
                        let grf = GRFDocument(fileURL: url)
                        return .grf(grf)
                    default:
                        return .previewItem(.url(url))
                    }
                }
            return children
        case .grf(let grf):
            return DocumentItem.grfDirectory(grf, "data\\").children
        case .grfDirectory(let grf, let path):
            var children: [DocumentItem] = []
            let nodes = grf.node(atPath: path)?.children ?? []
            for node in nodes {
                if node.isDirectory {
                    let path = "\(path)\(node.name)\\"
                    let child: DocumentItem = .grfDirectory(grf, path)
                    children.append(child)
                } else {
                    let child: DocumentItem = .previewItem(.grf(grf, node))
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
        case .directory, .grfDirectory:
            return 0
        default:
            return 1
        }
    }
}
