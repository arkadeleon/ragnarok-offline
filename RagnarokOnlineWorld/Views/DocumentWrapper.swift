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

    case archive(GRFArchive)

    case directoryInArchive(GRFArchive, String)

    case entryInArchive(String)

    case textDocument(TextDocument)
}

extension DocumentWrapper {

    var icon: UIImage? {
        switch self {
        case .directory:
            return UIImage(systemName: "folder")
        case .document:
            return UIImage(systemName: "doc")
        case .archive:
            return UIImage(systemName: "doc")
        case .directoryInArchive:
            return UIImage(systemName: "folder")
        case .entryInArchive:
            return UIImage(systemName: "doc")
        case .textDocument:
            return UIImage(systemName: "doc.text")
        }
    }

    var name: String {
        switch self {
        case .directory(let url):
            return url.lastPathComponent
        case .document(let url):
            return url.lastPathComponent
        case .archive(let archive):
            return archive.url.lastPathComponent
        case .directoryInArchive(_, let path):
            return String(path.split(separator: "\\").last ?? "")
        case .entryInArchive(let name):
            return name
        case .textDocument(let document):
            return document.name
        }
    }

    var documentWrappers: [String : DocumentWrapper]? {
        switch self {
        case .directory(let url):
            guard let urls = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []) else {
                return nil
            }
            let urlsWithNames = Dictionary(uniqueKeysWithValues: zip(urls.map { $0.lastPathComponent }, urls))
            let documentWrappers = urlsWithNames.mapValues { url -> DocumentWrapper in
                if url.hasDirectoryPath {
                    return .directory(url)
                }
                switch url.pathExtension {
                case "grf":
                    if let archive = try? GRFArchive(url: url) {
                        return .archive(archive)
                    } else {
                        return .document(url)
                    }
                case "txt", "xml", "lua", "lub":
                    let document = TextDocument(source: .url(url))
                    return .textDocument(document)
                default:
                    return .document(url)
                }
            }
            return documentWrappers
        case .document:
            return nil
        case .archive(let archive):
            return DocumentWrapper.directoryInArchive(archive, "data").documentWrappers
        case .directoryInArchive(let archive, let path):
            var documentWrappers: [String : DocumentWrapper] = [:]
            for entry in archive.entries where entry.path.hasPrefix(path) {
                let relativePath = entry.path.dropFirst(path.count)
                let pathComponents = relativePath.split(separator: "\\")
                if pathComponents.count == 1 {
                    let pathComponent = String(pathComponents[0])
                    let pathExtension = (pathComponent as NSString).pathExtension
                    switch pathExtension {
                    case "txt", "xml", "lua", "lub":
                        let textDocument = TextDocument(source: .entryInArchive(archive, entry))
                        let documentWrapper: DocumentWrapper = .textDocument(textDocument)
                        documentWrappers[pathComponent] = documentWrapper
                    default:
                        let documentWrapper: DocumentWrapper = .entryInArchive(entry.lastPathComponent)
                        documentWrappers[pathComponent] = documentWrapper
                    }
                } else if pathComponents.count > 1 {
                    let pathComponent = String(pathComponents[0])
                    if documentWrappers[pathComponent] == nil {
                        let path = path.appending("\\").appending(pathComponent)
                        let documentWrapper: DocumentWrapper = .directoryInArchive(archive, path)
                        documentWrappers[pathComponent] = documentWrapper
                    }
                }
            }
            return documentWrappers
        case .entryInArchive:
            return nil
        case .textDocument:
            return nil
        }
    }
}

extension DocumentWrapper: Equatable, Comparable {

    static func < (lhs: DocumentWrapper, rhs: DocumentWrapper) -> Bool {
        if lhs.rank == rhs.rank {
            return lhs.name.lowercased() < rhs.name.lowercased()
        } else {
            return lhs.rank < rhs.rank
        }
    }

    var rank: Int {
        switch self {
        case .directory:
            return 0
        case .document:
            return 1
        case .archive:
            return 1
        case .directoryInArchive:
            return 0
        case .entryInArchive:
            return 1
        case .textDocument:
            return 1
        }
    }
}
