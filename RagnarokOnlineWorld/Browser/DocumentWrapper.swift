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
    case text(DocumentSource)
    case image(DocumentSource)
    case model(DocumentSource)
    case world(DocumentSource)
    case sprite(DocumentSource)
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
        case .text(let source),
             .image(let source),
             .model(let source),
             .world(let source),
             .sprite(let source):
            switch source {
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
            return UIImage(systemName: "doc")
        case .entryGroup:
            return UIImage(systemName: "folder")
        case .entry:
            return UIImage(systemName: "doc")
        case .text:
            return UIImage(systemName: "doc.text")
        case .image:
            return UIImage(systemName: "doc.richtext")
        case .model:
            return UIImage(systemName: "square.stack.3d.up")
        case .world:
            return UIImage(systemName: "doc")
        case .sprite:
            return UIImage(systemName: "doc.richtext")
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
                    case "lua":
                        return .text(.url(url))
                    case "bmp", "jpg", "jpeg":
                        return .image(.url(url))
                    case "rsm":
                        return .model(.url(url))
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
            guard let grf = ResourceManager.default.grf(for: url) else {
                return []
            }
            var documentWrappers: [DocumentWrapper] = []
            let entryNames = grf.entryNames(forPath: path)
            for entryName in entryNames {
                if let index = entryName.firstIndex(of: ".") {
                    switch entryName[index...].lowercased() {
                    case ".lua":
                        let documentWrapper: DocumentWrapper = .text(.entry(url, entryName))
                        documentWrappers.append(documentWrapper)
                    case ".bmp", ".jpg", ".jpeg":
                        let documentWrapper: DocumentWrapper = .image(.entry(url, entryName))
                        documentWrappers.append(documentWrapper)
                    case ".pal":
                        let documentWrapper: DocumentWrapper = .image(.entry(url, entryName))
                        documentWrappers.append(documentWrapper)
                    case ".rsm":
                        let documentWrapper: DocumentWrapper = .model(.entry(url, entryName))
                        documentWrappers.append(documentWrapper)
                    case ".gnd":
                        let documentWrapper: DocumentWrapper = .world(.entry(url, entryName))
                        documentWrappers.append(documentWrapper)
                    case ".spr":
                        let documentWrapper: DocumentWrapper = .sprite(.entry(url, entryName))
                        documentWrappers.append(documentWrapper)
                    default:
                        let documentWrapper: DocumentWrapper = .entry(url, entryName)
                        documentWrappers.append(documentWrapper)
                    }
                } else {
                    let documentWrapper: DocumentWrapper = .entryGroup(url, entryName + "\\")
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
        case .model:
            return nil
        case .world:
            return nil
        case .sprite:
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
