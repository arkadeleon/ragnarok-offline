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

    case grfDocument(GRFDocument)

    case grfDocumentDirectory(GRFDocument, String)

    case grfDocumentEntry(GRFDocument.Entry)

    case regularDocument(URL)
}

extension DocumentWrapper {

    var icon: UIImage? {
        switch self {
        case .directory:
            return UIImage(systemName: "folder")
        case .grfDocument:
            return UIImage(systemName: "doc")
        case .grfDocumentDirectory:
            return UIImage(systemName: "folder")
        case .grfDocumentEntry:
            return UIImage(systemName: "doc")
        case .regularDocument:
            return UIImage(systemName: "doc")
        }
    }

    var name: String {
        switch self {
        case .directory(let directory):
            return directory.lastPathComponent
        case .grfDocument(let grf):
            return grf.url.lastPathComponent
        case .grfDocumentDirectory(_, let directory):
            return String(directory.split(separator: "\\").last ?? "")
        case .grfDocumentEntry(let entry):
            return String(entry.filename.split(separator: "\\").last ?? "")
        case .regularDocument(let url):
            return url.lastPathComponent
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
                    if let grf = try? GRFDocument(url: url) {
                        return .grfDocument(grf)
                    }
                default:
                    break
                }
                return .regularDocument(url)
            }
            return documentWrappers.sorted()
        case .grfDocument(let grf):
            return DocumentWrapper.grfDocumentDirectory(grf, "data").documentWrappers
        case .grfDocumentDirectory(let grf, let directory):
            var documentWrappers: [DocumentWrapper] = []
            for entry in grf.entries where entry.filename.hasPrefix(directory) {
                var filename = entry.filename
                filename.removeSubrange(directory.startIndex..<directory.endIndex)
                let components = filename.split(separator: "\\")
                if components.count == 1 {
                    let documentWrapper: DocumentWrapper = .grfDocumentEntry(entry)
                    documentWrappers.append(documentWrapper)
                } else if components.count > 1 {
                    let directory = directory.appending("\\").appending(components[0])
                    let documentWrapper: DocumentWrapper = .grfDocumentDirectory(grf, directory)
                    if !documentWrappers.contains(documentWrapper) {
                        documentWrappers.append(documentWrapper)
                    }
                }
            }
            return documentWrappers.sorted()
        case .grfDocumentEntry:
            return nil
        case .regularDocument:
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
        case .grfDocument:
            return 1
        case .grfDocumentDirectory:
            return 0
        case .grfDocumentEntry:
            return 1
        case .regularDocument:
            return 1
        }
    }
}
