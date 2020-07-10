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
    case grf(URL, GRFDocument)
    case entryGroup(URL, GRFDocument, String)
    case entry(URL, GRFDocument, String)
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
        case .grf(let url, _):
            return url
        case .entryGroup(let url, _, let path):
            return url.appendingPathComponent(path.replacingOccurrences(of: "\\", with: "/"))
        case .entry(let url, _, let entryName):
            return url.appendingPathComponent(entryName.replacingOccurrences(of: "\\", with: "/"))
        case .text(let source),
             .image(let source),
             .model(let source),
             .world(let source),
             .sprite(let source):
            switch source {
            case .url(let url):
                return url
            case .entry(let url, _, let entryName):
                return url.appendingPathComponent(entryName.replacingOccurrences(of: "\\", with: "/"))
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
            let documentWrappers = urls.map { url -> DocumentWrapper in
                if url.hasDirectoryPath {
                    return .directory(url)
                }
                switch url.pathExtension {
                case "grf":
                    let loader = DocumentLoader()
                    if let document = try? loader.load(GRFDocument.self, from: url) {
                        return .grf(url, document)
                    } else {
                        return .regular(url)
                    }
                case "lua":
                    return .text(.url(url))
                case "bmp":
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
        case .grf(let url, let document):
            return DocumentWrapper.entryGroup(url, document, "data\\").documentWrappers
        case .entryGroup(let url, let grf, let path):
            var documentWrappers: [DocumentWrapper] = []

            let entryNames = grf.entryNames(forPath: path)
            for entryName in entryNames {
                if let index = entryName.firstIndex(of: ".") {
                    switch entryName[index...] {
                    case ".lua":
                        let documentWrapper: DocumentWrapper = .text(.entry(url, grf, entryName))
                        documentWrappers.append(documentWrapper)
                    case ".bmp":
                        let documentWrapper: DocumentWrapper = .image(.entry(url, grf, entryName))
                        documentWrappers.append(documentWrapper)
                    case ".pal":
                        let documentWrapper: DocumentWrapper = .image(.entry(url, grf, entryName))
                        documentWrappers.append(documentWrapper)
                    case ".rsm":
                        let documentWrapper: DocumentWrapper = .model(.entry(url, grf, entryName))
                        documentWrappers.append(documentWrapper)
                    case ".gnd":
                        let documentWrapper: DocumentWrapper = .world(.entry(url, grf, entryName))
                        documentWrappers.append(documentWrapper)
                    case ".spr":
                        let documentWrapper: DocumentWrapper = .sprite(.entry(url, grf, entryName))
                        documentWrappers.append(documentWrapper)
                    default:
                        let documentWrapper: DocumentWrapper = .entry(url, grf, entryName)
                        documentWrappers.append(documentWrapper)
                    }
                } else {
                    let documentWrapper: DocumentWrapper = .entryGroup(url, grf, entryName + "\\")
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
        switch (lhs.url.pathExtension.isEmpty, rhs.url.pathExtension.isEmpty) {
        case (true, true),
             (false, false):
            return lhs.url.path.lowercased() < rhs.url.path.lowercased()
        case (true, false):
            return true
        case (false, true):
            return false
        }
    }
}
