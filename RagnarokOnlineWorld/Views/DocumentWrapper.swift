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

    case directoryInArchive(GRFArchive, String)

    case archive(GRFArchive)

    case textDocument(TextDocument)

    case unknownDocument(String)

    case unknownEntryInArchive(String)
}

extension DocumentWrapper {

    var icon: UIImage? {
        switch self {
        case .directory:
            return UIImage(systemName: "folder")
        case .directoryInArchive:
            return UIImage(systemName: "folder")
        case .archive:
            return UIImage(systemName: "doc")
        case .textDocument:
            return UIImage(systemName: "doc.text")
        case .unknownDocument:
            return UIImage(systemName: "doc")
        case .unknownEntryInArchive:
            return UIImage(systemName: "doc")
        }
    }

    var name: String {
        switch self {
        case .directory(let directory):
            return directory.lastPathComponent
        case .directoryInArchive(_, let directory):
            return String(directory.split(separator: "\\").last ?? "")
        case .archive(let archive):
            return archive.url.lastPathComponent
        case .textDocument(let document):
            return document.name
        case .unknownDocument(let name):
            return name
        case .unknownEntryInArchive(let name):
            return name
        }
    }

    var documentWrappers: [DocumentWrapper]? {
        switch self {
        case .directory(let directory):
            guard let urls = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: []) else {
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
                    }
                case "txt", "xml", "lua", "lub":
                    let document = TextDocument(source: .url(url))
                    return .textDocument(document)
                default:
                    break
                }
                return .unknownDocument(url.lastPathComponent)
            }
            return documentWrappers.sorted()
        case .directoryInArchive(let archive, let directory):
            var documentWrappers: [DocumentWrapper] = []
            for entry in archive.entries where entry.path.hasPrefix(directory) {
                var filename = entry.path
                filename.removeSubrange(directory.startIndex..<directory.endIndex)
                let components = filename.split(separator: "\\")
                if components.count == 1 {
                    let component = String(components[0]) as NSString
                    switch component.pathExtension {
                    case "txt", "xml", "lua", "lub":
                        let textDocument = TextDocument(source: .entryInArchive(archive, entry))
                        let documentWrapper: DocumentWrapper = .textDocument(textDocument)
                        documentWrappers.append(documentWrapper)
                    default:
                        let documentWrapper: DocumentWrapper = .unknownEntryInArchive(entry.lastPathComponent)
                        documentWrappers.append(documentWrapper)
                    }

                } else if components.count > 1 {
                    let directory = directory.appending("\\").appending(components[0])
                    let documentWrapper: DocumentWrapper = .directoryInArchive(archive, directory)
                    if !documentWrappers.contains(documentWrapper) {
                        documentWrappers.append(documentWrapper)
                    }
                }
            }
            return documentWrappers.sorted()
        case .archive(let archive):
            return DocumentWrapper.directoryInArchive(archive, "data").documentWrappers
        case .textDocument:
            return nil
        case .unknownDocument:
            return nil
        case .unknownEntryInArchive:
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
        case .directoryInArchive:
            return 0
        case .archive:
            return 1
        case .textDocument:
            return 1
        case .unknownDocument:
            return 1
        case .unknownEntryInArchive:
            return 1
        }
    }
}
