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

    case imageDocument(ImageDocument)
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
        case .imageDocument:
            return UIImage(systemName: "doc.richtext")
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
        case .imageDocument(let document):
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
                case "txt", "xml", "lua":
                    let document = TextDocument(source: .url(url))
                    return .textDocument(document)
                case "bmp", "jpg", "jpeg":
                    let document = ImageDocument(source: .url(url))
                    return .imageDocument(document)
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
            let nodes = archive.nodes(withPath: path)
            for node in nodes {
                if let entry = node.entry {
                    let pathExtension = (node.pathComponent as NSString).pathExtension
                    switch pathExtension {
                    case "txt", "xml", "lua":
                        let textDocument = TextDocument(source: .entryInArchive(archive, entry))
                        let documentWrapper: DocumentWrapper = .textDocument(textDocument)
                        documentWrappers[node.pathComponent] = documentWrapper
                    case "bmp", "jpg", "jpeg":
                        let imageDocument = ImageDocument(source: .entryInArchive(archive, entry))
                        let documentWrapper: DocumentWrapper = .imageDocument(imageDocument)
                        documentWrappers[node.pathComponent] = documentWrapper
                    default:
                        let documentWrapper: DocumentWrapper = .entryInArchive(entry.lastPathComponent)
                        documentWrappers[node.pathComponent] = documentWrapper
                    }
                } else {
                    let path = path.appending("\\").appending(node.pathComponent)
                    let documentWrapper: DocumentWrapper = .directoryInArchive(archive, path)
                    documentWrappers[node.pathComponent] = documentWrapper
                }
            }
            return documentWrappers
        case .entryInArchive:
            return nil
        case .textDocument:
            return nil
        case .imageDocument:
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
        case .imageDocument:
            return 1
        }
    }
}
