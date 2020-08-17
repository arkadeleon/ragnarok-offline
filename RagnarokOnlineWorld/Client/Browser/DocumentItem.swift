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
    case regular(URL)
    case grf(GRFTree)
    case entryGroup(GRFTree, String)
    case entry(URL, String)
    case text(PreviewItem)
    case image(PreviewItem)
    case audio(PreviewItem)
    case sprite(PreviewItem)
    case action(PreviewItem)
    case model(PreviewItem)
    case world(PreviewItem)
}

extension DocumentItem {

    var url: URL {
        switch self {
        case .directory(let url):
            return url
        case .regular(let url):
            return url
        case .grf(let tree):
            return tree.url
        case .entryGroup(let tree, let path):
            return tree.url.appendingPathComponent(path.replacingOccurrences(of: "\\", with: "/"))
        case .entry(let url, let name):
            return url.appendingPathComponent(name.replacingOccurrences(of: "\\", with: "/"))
        case .text(let previewItem),
             .image(let previewItem),
             .audio(let previewItem),
             .sprite(let previewItem),
             .action(let previewItem),
             .model(let previewItem),
             .world(let previewItem):
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
        case .regular:
            return UIImage(systemName: "doc")
        case .grf:
            return UIImage(systemName: "doc.zipper")
        case .entryGroup:
            return UIImage(systemName: "folder")
        case .entry:
            return UIImage(systemName: "doc")
        case .text:
            return UIImage(systemName: "doc.text")
        case .image:
            return UIImage(systemName: "photo")
        case .audio:
            return UIImage(systemName: "waveform.circle")
        case .sprite:
            return UIImage(systemName: "photo")
        case .action:
            return UIImage(systemName: "bolt")
        case .model:
            return UIImage(systemName: "square.stack.3d.up")
        case .world:
            return UIImage(systemName: "map")
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
                    case "txt", "xml", "ini", "lua", "lub":
                        return .text(.url(url))
                    case "bmp", "jpg", "jpeg", "tga", "pal":
                        return .image(.url(url))
                    case "mp3", "wav":
                        return .audio(.url(url))
                    default:
                        return .regular(url)
                    }
                }
            return children
        case .regular:
            return nil
        case .grf(let tree):
            return DocumentItem.entryGroup(tree, "data\\").children
        case .entryGroup(let tree, let path):
            var children: [DocumentItem] = []
            let nodes = tree.nodes(withPath: path)
            for node in nodes {
                if let entry = node.entry {
                    switch (entry.name as NSString).pathExtension.lowercased() {
                    case "txt", "xml", "ini", "lua", "lub":
                        let child: DocumentItem = .text(.entry(tree, entry.name))
                        children.append(child)
                    case "bmp", "jpg", "jpeg", "tga", "pal":
                        let child: DocumentItem = .image(.entry(tree, entry.name))
                        children.append(child)
                    case "mp3", "wav":
                        let child: DocumentItem = .audio(.entry(tree, entry.name))
                        children.append(child)
                    case "spr":
                        let child: DocumentItem = .sprite(.entry(tree, entry.name))
                        children.append(child)
                    case "act":
                        let child: DocumentItem = .action(.entry(tree, entry.name))
                        children.append(child)
                    case "rsm":
                        let child: DocumentItem = .model(.entry(tree, entry.name))
                        children.append(child)
                    case "rsw":
                        let child: DocumentItem = .world(.entry(tree, entry.name))
                        children.append(child)
                    default:
                        let child: DocumentItem = .entry(url, entry.name)
                        children.append(child)
                    }
                } else {
                    let path = "\(path)\(node.pathComponent)\\"
                    let child: DocumentItem = .entryGroup(tree, path)
                    children.append(child)
                }
            }
            return children
        case .entry:
            return nil
        case .text:
            return nil
        case .image:
            return nil
        case .audio:
            return nil
        case .sprite:
            return nil
        case .action:
            return nil
        case .model:
            return nil
        case .world:
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
