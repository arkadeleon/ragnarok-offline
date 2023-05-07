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
    case grf(GRFDocument)
    case grfNode(GRFDocument, GRFTreeNode)

    var isDirectory: Bool {
        switch self {
        case .url(let url):
            let values = try? url.resourceValues(forKeys: [.isDirectoryKey])
            return values?.isDirectory == true
        case .grf:
            return false
        case .grfNode(_, let node):
            return node.isDirectory
        }
    }

    var isArchive: Bool {
        switch self {
        case .url:
            return false
        case .grf:
            return true
        case .grfNode:
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
        case .grfNode(_, let node):
            let pathExtension = node.name.split(separator: "\\").last?.split(separator: ".").last
            let fileType = FileType(rawValue: String(pathExtension ?? ""))
            return fileType
        }
    }

    var url: URL {
        switch self {
        case .url(let url):
            return url
        case .grf(let grf):
            return grf.url
        case .grfNode(let grf, let node):
            let name = node.name.replacing("\\", with: "/")
            return grf.url.appendingPathComponent(name)
        }
    }

    var name: String {
        switch self {
        case .url(let url):
            return url.lastPathComponent
        case .grf(let grf):
            return grf.url.lastPathComponent
        case .grfNode(_, let node):
            let lastPathComponent = node.name.split(separator: "\\").last
            return String(lastPathComponent ?? "")
        }
    }

    func contents() -> Data? {
        switch self {
        case .url(let url) where !isDirectory:
            return try? Data(contentsOf: url)
        case .grf:
            return nil
        case .grfNode(_, let node) where !isDirectory:
            return node.contents
        default:
            return nil
        }
    }

    func documentWrappers() -> [DocumentWrapper] {
        var documentWrappers: [DocumentWrapper] = []

        switch self {
        case .url(let url) where isDirectory:
            guard let urls = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []) else {
                break
            }
            documentWrappers = urls.map({ $0.resolvingSymlinksInPath() }).map { url -> DocumentWrapper in
                switch url.pathExtension.lowercased() {
                case "grf":
                    let grf = GRFDocument(fileURL: url)
                    return .grf(grf)
                default:
                    return .url(url)
                }
            }
        case .grf(let grf):
            guard let node = grf.node(atPath: "data\\") else {
                break
            }
            let documentWrapper = DocumentWrapper.grfNode(grf, node)
            documentWrappers = documentWrapper.documentWrappers()
        case .grfNode(let grf, let node) where isDirectory:
            documentWrappers = node.children.map { node in
                DocumentWrapper.grfNode(grf, node)
            }
        default:
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
        case .grfNode(_, let node):
            guard let contents = node.contents else {
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
