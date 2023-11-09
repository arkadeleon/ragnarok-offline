//
//  DocumentWrapper.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/18.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import UIKit

enum DocumentWrapper {

    case url(URL)
    case grf(GRFTree)
    case grfDirectory(GRFTree, String)
    case grfEntry(GRFTree, String)

    var isDirectory: Bool {
        switch self {
        case .url(let url):
            let values = try? url.resourceValues(forKeys: [.isDirectoryKey])
            return values?.isDirectory == true
        case .grf:
            return false
        case .grfDirectory:
            return true
        case .grfEntry:
            return false
        }
    }

    var isArchive: Bool {
        switch self {
        case .url:
            return false
        case .grf:
            return true
        case .grfDirectory:
            return false
        case .grfEntry:
            return false
        }
    }

    var contentType: FileType? {
        if isDirectory {
            return nil
        }

        switch self {
        case .url(let url):
            let fileType = FileType(rawValue: url.pathExtension)
            return fileType
        case .grf:
            return nil
        case .grfDirectory:
            return nil
        case .grfEntry(_, let path):
            let pathExtension = path.split(separator: "\\").last?.split(separator: ".").last
            let fileType = FileType(rawValue: String(pathExtension ?? ""))
            return fileType
        }
    }

    var url: URL {
        switch self {
        case .url(let url):
            return url
        case .grf(let tree):
            return tree.url
        case .grfDirectory(let tree, let path):
            let path = path.replacing("\\", with: "/")
            return tree.url.appendingPathComponent(path)
        case .grfEntry(let tree, let path):
            let path = path.replacing("\\", with: "/")
            return tree.url.appendingPathComponent(path)
        }
    }

    var name: String {
        switch self {
        case .url(let url):
            return url.lastPathComponent
        case .grf(let tree):
            return tree.url.lastPathComponent
        case .grfDirectory(_, let path):
            let lastPathComponent = path.split(separator: "\\").last
            return String(lastPathComponent ?? "")
        case .grfEntry(_, let path):
            let lastPathComponent = path.split(separator: "\\").last
            return String(lastPathComponent ?? "")
        }
    }

    func contents() -> Data? {
        switch self {
        case .url(let url):
            if isDirectory {
                return nil
            } else {
                return try? Data(contentsOf: url)
            }
        case .grf:
            return nil
        case .grfDirectory:
            return nil
        case .grfEntry(let tree, let path):
            return try? tree.contentsOfEntry(withName: path)
        }
    }

    func documentWrappers() -> [DocumentWrapper] {
        var documentWrappers: [DocumentWrapper] = []

        switch self {
        case .url(let url):
            guard isDirectory else {
                break
            }
            guard let urls = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []) else {
                break
            }
            documentWrappers = urls.map({ $0.resolvingSymlinksInPath() }).map { url -> DocumentWrapper in
                switch url.pathExtension.lowercased() {
                case "grf":
                    let tree = GRFTree(url: url)
                    return .grf(tree)
                default:
                    return .url(url)
                }
            }
        case .grf(let tree):
            let documentWrapper = DocumentWrapper.grfDirectory(tree, "data\\")
            documentWrappers = documentWrapper.documentWrappers()
        case .grfDirectory(let tree, let path):
            let nodes = tree.nodes(withPath: path)
            for node in nodes {
                if let entry = node.entry {
                    let documentWrapper = DocumentWrapper.grfEntry(tree, entry.name)
                    documentWrappers.append(documentWrapper)
                } else {
                    let path = "\(path)\(node.pathComponent)\\"
                    let documentWrapper = DocumentWrapper.grfDirectory(tree, path)
                    documentWrappers.append(documentWrapper)
                }
            }
        case .grfEntry:
            break
        }

        return documentWrappers
    }

    func pasteFromPasteboard(_ pasteboard: DocumentPasteboard) -> DocumentWrapper? {
        guard let sourceDocument = pasteboard.document else {
            return nil
        }

        guard case .url(let url) = self else {
            return nil
        }

        let destinationDocument = DocumentWrapper.url(url.appending(path: sourceDocument.name))
        switch sourceDocument {
        case .url:
            do {
                try FileManager.default.copyItem(at: sourceDocument.url, to: destinationDocument.url)
                return destinationDocument
            } catch {
                return nil
            }
        case .grf:
            return nil
        case .grfDirectory:
            return nil
        case .grfEntry(let tree, let path):
            guard let contents = try? tree.contentsOfEntry(withName: path) else {
                return nil
            }
            do {
                try contents.write(to: destinationDocument.url)
                return destinationDocument
            } catch {
                return nil
            }
        }
    }
}

extension DocumentWrapper: Identifiable {
    var id: URL {
        url
    }
}

extension DocumentWrapper: Comparable {
    static func < (lhs: DocumentWrapper, rhs: DocumentWrapper) -> Bool {
        if lhs.isDirectory == rhs.isDirectory {
            return lhs.name.lowercased() < rhs.name.lowercased()
        } else {
            let lhsRank = lhs.isDirectory ? 0 : 1
            let rhsRank = rhs.isDirectory ? 0 : 1
            return lhsRank < rhsRank
        }
    }

    static func == (lhs: DocumentWrapper, rhs: DocumentWrapper) -> Bool {
        lhs.id == rhs.id
    }
}
