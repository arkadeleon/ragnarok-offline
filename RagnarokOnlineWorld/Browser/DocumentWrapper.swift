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
    case document(URL)
    case grfDocument(URL, GRFDocument)
    case directoryInArchive(URL, GRFDocument, String)
    case entryInArchive(URL, GRFDocument, String)
    case textDocument(DocumentSource)
    case imageDocument(DocumentSource)
    case rsmDocument(DocumentSource)
    case gndDocument(DocumentSource)
    case sprite(DocumentSource)
}

extension DocumentWrapper {

    var url: URL {
        switch self {
        case .directory(let url):
            return url
        case .document(let url):
            return url
        case .grfDocument(let url, _):
            return url
        case .directoryInArchive(let url, _, let path):
            return url.appendingPathComponent(path.replacingOccurrences(of: "\\", with: "/"))
        case .entryInArchive(let url, _, let entryName):
            return url.appendingPathComponent(entryName.replacingOccurrences(of: "\\", with: "/"))
        case .textDocument(let source),
             .imageDocument(let source),
             .rsmDocument(let source),
             .gndDocument(let source),
             .sprite(let source):
            switch source {
            case .url(let url):
                return url
            case .entryInArchive(let url, _, let entryName):
                return url.appendingPathComponent(entryName.replacingOccurrences(of: "\\", with: "/"))
            }
        }
    }

    var icon: UIImage? {
        switch self {
        case .directory:
            return UIImage(systemName: "folder")
        case .document:
            return UIImage(systemName: "doc")
        case .grfDocument:
            return UIImage(systemName: "doc")
        case .directoryInArchive:
            return UIImage(systemName: "folder")
        case .entryInArchive:
            return UIImage(systemName: "doc")
        case .textDocument:
            return UIImage(systemName: "doc.text")
        case .imageDocument:
            return UIImage(systemName: "doc.richtext")
        case .rsmDocument:
            return UIImage(systemName: "square.stack.3d.up")
        case .gndDocument:
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
                        return .grfDocument(url, document)
                    } else {
                        return .document(url)
                    }
                case "lua":
                    return .textDocument(.url(url))
                case "bmp":
                    return .imageDocument(.url(url))
                case "rsm":
                    return .rsmDocument(.url(url))
                default:
                    return .document(url)
                }
            }
            return documentWrappers
        case .document:
            return nil
        case .grfDocument(let url, let document):
            return DocumentWrapper.directoryInArchive(url, document, "data\\").documentWrappers
        case .directoryInArchive(let url, let archive, let path):
            var documentWrappers: [DocumentWrapper] = []

            let entryNames = archive.entryNames(forPath: path)
            for entryName in entryNames {
                if let index = entryName.firstIndex(of: ".") {
                    switch entryName[index...] {
                    case ".lua":
                        let documentWrapper: DocumentWrapper = .textDocument(.entryInArchive(url, archive, entryName))
                        documentWrappers.append(documentWrapper)
                    case ".bmp":
                        let documentWrapper: DocumentWrapper = .imageDocument(.entryInArchive(url, archive, entryName))
                        documentWrappers.append(documentWrapper)
                    case ".pal":
                        let documentWrapper: DocumentWrapper = .imageDocument(.entryInArchive(url, archive, entryName))
                        documentWrappers.append(documentWrapper)
                    case ".rsm":
                        let documentWrapper: DocumentWrapper = .rsmDocument(.entryInArchive(url, archive, entryName))
                        documentWrappers.append(documentWrapper)
                    case ".gnd":
                        let documentWrapper: DocumentWrapper = .gndDocument(.entryInArchive(url, archive, entryName))
                        documentWrappers.append(documentWrapper)
                    case ".spr":
                        let documentWrapper: DocumentWrapper = .sprite(.entryInArchive(url, archive, entryName))
                        documentWrappers.append(documentWrapper)
                    default:
                        let documentWrapper: DocumentWrapper = .entryInArchive(url, archive, entryName)
                        documentWrappers.append(documentWrapper)
                    }
                } else {
                    let documentWrapper: DocumentWrapper = .directoryInArchive(url, archive, entryName + "\\")
                    documentWrappers.append(documentWrapper)
                }
            }

            return documentWrappers
        case .entryInArchive:
            return nil
        case .textDocument:
            return nil
        case .imageDocument:
            return nil
        case .rsmDocument:
            return nil
        case .gndDocument:
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
