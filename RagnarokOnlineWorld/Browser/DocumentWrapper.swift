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
    case luaDocument(LUADocument)
    case imageDocument(Document<CGImage>)
    case rsmDocument(RSMDocument)
    case gndDocument(GNDDocument)
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
        case .luaDocument:
            return UIImage(systemName: "doc.text")
        case .imageDocument:
            return UIImage(systemName: "doc.richtext")
        case .rsmDocument:
            return UIImage(systemName: "square.stack.3d.up")
        case .gndDocument:
            return UIImage(systemName: "doc")
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
        case .entryInArchive(let entryName):
            return String(entryName.split(separator: "\\").last ?? "")
        case .luaDocument(let document):
            return document.name
        case .imageDocument(let document):
            return document.name
        case .rsmDocument(let document):
            return document.name
        case .gndDocument(let document):
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
                case "lua":
                    let document = LUADocument(source: .url(url))
                    return .luaDocument(document)
                case "bmp":
                    let document = BMPDocument(source: .url(url))
                    return .imageDocument(document)
                case "rsm":
                    let document = RSMDocument(source: .url(url))
                    return .rsmDocument(document)
                default:
                    return .document(url)
                }
            }
            return documentWrappers
        case .document:
            return nil
        case .archive(let archive):
            return DocumentWrapper.directoryInArchive(archive, "data\\").documentWrappers
        case .directoryInArchive(let archive, let path):
            archive.unarchive()

            var documentWrappers: [DocumentWrapper] = []

            let entryNames = archive.entryNames(forPath: path)
            for entryName in entryNames {
                if let index = entryName.firstIndex(of: ".") {
                    switch entryName[index...] {
                    case ".lua":
                        let document = LUADocument(source: .entryInArchive(archive, entryName))
                        let documentWrapper: DocumentWrapper = .luaDocument(document)
                        documentWrappers.append(documentWrapper)
                    case ".bmp":
                        let document = BMPDocument(source: .entryInArchive(archive, entryName))
                        let documentWrapper: DocumentWrapper = .imageDocument(document)
                        documentWrappers.append(documentWrapper)
                    case ".pal":
                        let document = PALDocument(source: .entryInArchive(archive, entryName))
                        let documentWrapper: DocumentWrapper = .imageDocument(document)
                        documentWrappers.append(documentWrapper)
                    case ".rsm":
                        let document = RSMDocument(source: .entryInArchive(archive, entryName))
                        let documentWrapper: DocumentWrapper = .rsmDocument(document)
                        documentWrappers.append(documentWrapper)
                    case ".gnd":
                        let document = GNDDocument(source: .entryInArchive(archive, entryName))
                        let documentWrapper: DocumentWrapper = .gndDocument(document)
                        documentWrappers.append(documentWrapper)
                    default:
                        let documentWrapper: DocumentWrapper = .entryInArchive(entryName)
                        documentWrappers.append(documentWrapper)
                    }
                } else {
                    let documentWrapper: DocumentWrapper = .directoryInArchive(archive, entryName + "\\")
                    documentWrappers.append(documentWrapper)
                }
            }

            return documentWrappers
        case .entryInArchive:
            return nil
        case .luaDocument:
            return nil
        case .imageDocument:
            return nil
        case .rsmDocument:
            return nil
        case .gndDocument:
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
        case .luaDocument:
            return 1
        case .imageDocument:
            return 1
        case .rsmDocument:
            return 1
        case .gndDocument:
            return 1
        }
    }
}
