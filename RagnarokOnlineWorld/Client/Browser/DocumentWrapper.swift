//
//  DocumentWrapper.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/7.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

enum DocumentWrapper {

    case directory(URL)
    case regular(URL)
    case grf(URL)
    case entryGroup(URL, String)
    case entry(URL, String)
    case text(PreviewItem)
    case image(PreviewItem)
    case audio(PreviewItem)
    case sprite(PreviewItem)
    case action(PreviewItem)
    case model(PreviewItem)
    case world(PreviewItem)
}

extension DocumentWrapper {

    var url: URL {
        switch self {
        case .directory(let url):
            return url
        case .regular(let url):
            return url
        case .grf(let url):
            return url
        case .entryGroup(let url, let path):
            return url.appendingPathComponent(path.replacingOccurrences(of: "\\", with: "/"))
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
            case .entry(let url, let name):
                return url.appendingPathComponent(name.replacingOccurrences(of: "\\", with: "/"))
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

    var documentWrappers: [DocumentWrapper]? {
        switch self {
        case .directory(let url):
            guard let urls = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []) else {
                return nil
            }
            let documentWrappers = urls
                .map{ url -> URL in
                    url.resolvingSymlinksInPath()
                }
                .map { url -> DocumentWrapper in
                    if url.hasDirectoryPath {
                        return .directory(url)
                    }
                    switch url.pathExtension.lowercased() {
                    case "grf":
                        return .grf(url)
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
            return documentWrappers
        case .regular:
            return nil
        case .grf(let url):
            return DocumentWrapper.entryGroup(url, "data\\").documentWrappers
        case .entryGroup(let url, let path):
            var documentWrappers: [DocumentWrapper] = []
            let nodes = try? ResourceManager.default.nodes(withPath: path, url: url)
            for node in nodes ?? [] {
                if let entry = node.entry {
                    switch (entry.name as NSString).pathExtension.lowercased() {
                    case "txt", "xml", "ini", "lua", "lub":
                        let documentWrapper: DocumentWrapper = .text(.entry(url, entry.name))
                        documentWrappers.append(documentWrapper)
                    case "bmp", "jpg", "jpeg", "tga", "pal":
                        let documentWrapper: DocumentWrapper = .image(.entry(url, entry.name))
                        documentWrappers.append(documentWrapper)
                    case "mp3", "wav":
                        let documentWrapper: DocumentWrapper = .audio(.entry(url, entry.name))
                        documentWrappers.append(documentWrapper)
                    case "spr":
                        let documentWrapper: DocumentWrapper = .sprite(.entry(url, entry.name))
                        documentWrappers.append(documentWrapper)
                    case "act":
                        let documentWrapper: DocumentWrapper = .action(.entry(url, entry.name))
                        documentWrappers.append(documentWrapper)
                    case "rsm":
                        let documentWrapper: DocumentWrapper = .model(.entry(url, entry.name))
                        documentWrappers.append(documentWrapper)
                    case "rsw":
                        let documentWrapper: DocumentWrapper = .world(.entry(url, entry.name))
                        documentWrappers.append(documentWrapper)
                    default:
                        let documentWrapper: DocumentWrapper = .entry(url, entry.name)
                        documentWrappers.append(documentWrapper)
                    }
                } else {
                    let path = "\(path)\(node.pathComponent)\\"
                    let documentWrapper: DocumentWrapper = .entryGroup(url, path)
                    documentWrappers.append(documentWrapper)
                }
            }

            return documentWrappers
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

extension DocumentWrapper: Equatable, Comparable {
    static func == (lhs: DocumentWrapper, rhs: DocumentWrapper) -> Bool {
        lhs.url == rhs.url
    }

    static func < (lhs: DocumentWrapper, rhs: DocumentWrapper) -> Bool {
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
