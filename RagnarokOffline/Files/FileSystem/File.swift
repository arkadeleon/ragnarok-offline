//
//  File.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/24.
//

import Foundation
import GRF
import Observation
import RagnarokResources
import TextEncoding
import UniformTypeIdentifiers

enum FileError: Error {
    case fileIsDirectory
    case imageGenerationFailed
    case stringConversionFailed
    case jsonConversionFailed
}

enum FileNode {
    case directory(URL)
    case regularFile(URL)
    case grfArchive(GRFArchive)
    case grfArchiveNode(GRFArchive, GRFNode)
}

enum FileLocation {
    case client
    case server
    case external
}

@Observable
final class File: Sendable {
    let node: FileNode
    let location: FileLocation

    let url: URL
    let name: String
    let `extension`: String

    var isDirectory: Bool {
        switch node {
        case .directory:
            true
        case .regularFile, .grfArchive:
            false
        case .grfArchiveNode(_, let node):
            node.isDirectory
        }
    }

    var isTextFile: Bool {
        utType.conforms(to: .text)
    }

    var isImageFile: Bool {
        utType.conforms(to: .image)
    }

    var isAudioFile: Bool {
        utType.conforms(to: .audio)
    }

    var hasFiles: Bool {
        switch node {
        case .directory, .grfArchive:
            true
        case .regularFile:
            false
        case .grfArchiveNode(_, let node):
            node.isDirectory
        }
    }

    var utType: UTType {
        switch node {
        case .directory:
            .folder
        case .regularFile, .grfArchive:
            UTType(filenameExtension: self.extension) ?? .data
        case .grfArchiveNode(_, let node):
            node.isDirectory ? .directory : UTType(filenameExtension: node.path.extension) ?? .data
        }
    }

    init(node: FileNode, location: FileLocation) {
        self.node = node
        self.location = location

        self.url = switch node {
        case .directory(let url):
            url
        case .regularFile(let url):
            url
        case .grfArchive(let grfArchive):
            grfArchive.url
        case .grfArchiveNode(let grfArchive, let node):
            grfArchive.url.appending(queryItems: [
                URLQueryItem(name: "path", value: node.path.string)
            ])
        }

        self.name = switch node {
        case .directory(let url):
            url.lastPathComponent
        case .regularFile(let url):
            url.lastPathComponent
        case .grfArchive(let grfArchive):
            grfArchive.url.lastPathComponent
        case .grfArchiveNode(_, let node):
            L2K(node.path.lastComponent)
        }

        self.extension = switch node {
        case .directory(let url):
            url.pathExtension
        case .regularFile(let url):
            url.pathExtension
        case .grfArchive(let grfArchive):
            grfArchive.url.pathExtension
        case .grfArchiveNode(_, let node):
            node.path.extension
        }
    }

    convenience init(_ locator: ResourceLocator) {
        let node: FileNode = switch locator {
        case .url(let url):
            .regularFile(url)
        case .grfArchiveNode(let grfArchive, let node):
            .grfArchiveNode(grfArchive, node)
        }

        self.init(node: node, location: .client)
    }

    func size() async -> Int {
        switch node {
        case .directory:
            return 0
        case .regularFile(let url):
            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
            return size
        case .grfArchive(let grfArchive):
            let size = (try? grfArchive.url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
            return size
        case .grfArchiveNode(let grfArchive, let node):
            if node.isDirectory {
                return 0
            } else {
                return await grfArchive.sizeOfEntryNode(at: node.path) ?? 0
            }
        }
    }

    func contents() async throws -> Data {
        switch node {
        case .directory:
            throw FileError.fileIsDirectory
        case .regularFile(let url):
            try Data(contentsOf: url)
        case .grfArchive:
            throw FileError.fileIsDirectory
        case .grfArchiveNode(let grfArchive, let node):
            if node.isDirectory {
                throw FileError.fileIsDirectory
            } else {
                try await grfArchive.contentsOfEntryNode(at: node.path)
            }
        }
    }

    func files() async -> [File] {
        switch node {
        case .directory(let url):
            let urls = (try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])) ?? []
            let files = urls.map({ $0.resolvingSymlinksInPath() }).map { url -> File in
                switch url.pathExtension.lowercased() {
                case "grf":
                    let grfArchive = GRFArchive(url: url)
                    return File(node: .grfArchive(grfArchive), location: location)
                default:
                    let values = try? url.resourceValues(forKeys: [.isDirectoryKey])
                    if values?.isDirectory == true {
                        return File(node: .directory(url), location: location)
                    } else {
                        return File(node: .regularFile(url), location: location)
                    }
                }
            }
            return files.sorted()
        case .regularFile:
            return []
        case .grfArchive(let grfArchive):
            let path = GRFPath(components: ["data"])
            guard let directoryNode = await grfArchive.directoryNode(at: path) else {
                return []
            }
            let file = File(node: .grfArchiveNode(grfArchive, directoryNode), location: location)
            return await file.files()
        case .grfArchiveNode(let grfArchive, let node):
            guard node.isDirectory else {
                return []
            }
            let children = await grfArchive.childrenOfDirectoryNode(at: node.path)
            let files = children.map { child in
                File(node: .grfArchiveNode(grfArchive, child), location: location)
            }
            return files.sorted()
        }
    }

    func fileCount() async -> Int {
        switch node {
        case .directory(let url):
            let urls = (try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])) ?? []
            return urls.count
        case .regularFile:
            return 0
        case .grfArchive(let grfArchive):
            let path = GRFPath(components: ["data"])
            guard let directoryNode = await grfArchive.directoryNode(at: path) else {
                return 0
            }
            let file = File(node: .grfArchiveNode(grfArchive, directoryNode), location: location)
            return await file.fileCount()
        case .grfArchiveNode(let grfArchive, let node):
            if node.isDirectory {
                let childCount = await grfArchive.childCountOfDirectoryNode(at: node.path)
                return childCount
            } else {
                return 0
            }
        }
    }
}

extension File {
    var canPreview: Bool {
        switch utType {
        case let utType where utType.conforms(to: .text):
            true
        case .lua, .lub:
            true
        case let utType where utType.conforms(to: .image):
            true
        case .ebm, .pal:
            true
        case let utType where utType.conforms(to: .audio):
            true
        case .act, .gat, .gnd, .rsm, .rsw, .spr, .str:
            true
        default:
            false
        }
    }
}

extension File: Equatable {
    static func == (lhs: File, rhs: File) -> Bool {
        lhs.url == rhs.url
    }
}

extension File: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}

extension File: Identifiable {
    var id: URL {
        url
    }
}
