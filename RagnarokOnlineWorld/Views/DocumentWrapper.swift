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
            return documentWrappers.sorted()
        case .document:
            return nil
        case .archive(let archive):
            return DocumentWrapper.directoryInArchive(archive, "data").documentWrappers
        case .directoryInArchive(let archive, let path):
            var documentWrappers: [DocumentWrapper] = []
            for entry in archive.entries where entry.path.hasPrefix(path) {
                let relativePath = entry.path.dropFirst(path.count)
                let components = relativePath.split(separator: "\\")
                if components.count == 1 {
                    let component = String(components[0]) as NSString
                    switch component.pathExtension {
                    case "txt", "xml", "lua", "lub":
                        let textDocument = TextDocument(source: .entryInArchive(archive, entry))
                        let documentWrapper: DocumentWrapper = .textDocument(textDocument)
                        documentWrappers.append(documentWrapper)
                    default:
                        let documentWrapper: DocumentWrapper = .entryInArchive(entry.lastPathComponent)
                        documentWrappers.append(documentWrapper)
                    }
                } else if components.count > 1 {
                    let path = path.appending("\\").appending(components[0])
                    let documentWrapper: DocumentWrapper = .directoryInArchive(archive, path)
                    if !documentWrappers.contains(documentWrapper) {
                        documentWrappers.append(documentWrapper)
                    }
                }
            }
            return documentWrappers.sorted()
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
