//
//  File.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/24.
//

import Foundation
import GRF
import Observation
import ROResources
import UniformTypeIdentifiers

enum FileNode {
    case directory(URL)
    case regularFile(URL)
    case grfArchive(GRFArchive)
    case grfArchiveDirectory(GRFArchive, GRFPath)
    case grfArchiveEntry(GRFArchive, GRFEntryNode)
}

@Observable
class File: Hashable, Identifiable {
    static func == (lhs: File, rhs: File) -> Bool {
        lhs.url == rhs.url
    }

    let node: FileNode

    @ObservationIgnored
    lazy var url: URL = {
        switch node {
        case .directory(let url):
            url
        case .regularFile(let url):
            url
        case .grfArchive(let grfArchive):
            grfArchive.url
        case .grfArchiveDirectory(let grfArchive, let path):
            grfArchive.url.appending(queryItems: [
                URLQueryItem(name: "path", value: path.string)
            ])
        case .grfArchiveEntry(let grfArchive, let entry):
            grfArchive.url.appending(queryItems: [
                URLQueryItem(name: "path", value: entry.path.string)
            ])
        }
    }()

    @ObservationIgnored
    lazy var name: String = {
        switch node {
        case .directory(let url):
            url.lastPathComponent
        case .regularFile(let url):
            url.lastPathComponent
        case .grfArchive(let grfArchive):
            grfArchive.url.lastPathComponent
        case .grfArchiveDirectory(_, let path):
            path.lastComponent.transcoding(from: .isoLatin1, to: .koreanEUC) ?? path.lastComponent
        case .grfArchiveEntry(_, let entry):
            entry.path.lastComponent.transcoding(from: .isoLatin1, to: .koreanEUC) ?? entry.path.lastComponent
        }
    }()

    @ObservationIgnored
    lazy var utType: UTType? = {
        if case .directory = node {
            return .folder
        }

        if case .grfArchiveDirectory = node {
            return .directory
        }

        let filenameExtension = switch node {
        case .directory(let url):
            url.pathExtension
        case .regularFile(let url):
            url.pathExtension
        case .grfArchive(let grfArchive):
            grfArchive.url.pathExtension
        case .grfArchiveDirectory(_, let path):
            path.extension
        case .grfArchiveEntry(_, let entry):
            entry.path.extension
        }

        let utType = UTType(filenameExtension: filenameExtension)
        return utType
    }()

    var id: URL {
        url
    }

    var isDirectory: Bool {
        switch node {
        case .directory, .grfArchiveDirectory:
            true
        case .regularFile, .grfArchive, .grfArchiveEntry:
            false
        }
    }

    var hasFiles: Bool {
        switch node {
        case .directory, .grfArchive, .grfArchiveDirectory:
            true
        case .regularFile, .grfArchiveEntry:
            false
        }
    }

    init(node: FileNode) {
        self.node = node
    }

    init(_ locator: ResourceLocator) {
        switch locator {
        case .url(let url):
            node = .regularFile(url)
        case .grfArchiveEntry(let grfArchive, let entry):
            node = .grfArchiveEntry(grfArchive, entry)
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
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
        case .grfArchiveDirectory:
            return 0
        case .grfArchiveEntry(_, let entry):
            return entry.size
        }
    }

    func contents() async -> Data? {
        switch node {
        case .directory:
            nil
        case .regularFile(let url):
            try? Data(contentsOf: url)
        case .grfArchive:
            nil
        case .grfArchiveDirectory:
            nil
        case .grfArchiveEntry(let grfArchive, let entry):
            try? await grfArchive.contentsOfEntry(at: entry.path)
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
                    return File(node: .grfArchive(grfArchive))
                default:
                    let values = try? url.resourceValues(forKeys: [.isDirectoryKey])
                    if values?.isDirectory == true {
                        return File(node: .directory(url))
                    } else {
                        return File(node: .regularFile(url))
                    }
                }
            }
            return files.sorted()
        case .regularFile:
            return []
        case .grfArchive(let grfArchive):
            let path = GRFPath(components: ["data"])
            let file = File(node: .grfArchiveDirectory(grfArchive, path))
            return await file.files()
        case .grfArchiveDirectory(let grfArchive, let path):
            guard let directory = await grfArchive.directory(at: path) else {
                return []
            }
            var files: [File] = []
            for subdirectory in directory.subdirectories {
                let file = File(node: .grfArchiveDirectory(grfArchive, subdirectory.path))
                files.append(file)
            }
            for entry in directory.entries {
                let file = File(node: .grfArchiveEntry(grfArchive, entry))
                files.append(file)
            }
            return files.sorted()
        case .grfArchiveEntry:
            return []
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
            let file = File(node: .grfArchiveDirectory(grfArchive, path))
            return await file.fileCount()
        case .grfArchiveDirectory(let grfArchive, let path):
            if let directory = await grfArchive.directory(at: path) {
                return directory.subdirectories.count + directory.entries.count
            } else {
                return 0
            }
        case .grfArchiveEntry:
            return 0
        }
    }

    func fetchThumbnail(size: CGSize, scale: CGFloat) async throws -> FileThumbnail? {
        let request = FileThumbnailRequest(file: self, size: size, scale: scale)
        let thumbnail = try await FileSystem.shared.thumbnail(for: request)
        return thumbnail
    }
}

extension File {
    var canPreview: Bool {
        guard let utType else {
            return false
        }

        switch utType {
        case let utType where utType.conforms(to: .text):
            return true
        case .lua, .lub:
            return true
        case let utType where utType.conforms(to: .image):
            return true
        case .ebm, .pal:
            return true
        case let utType where utType.conforms(to: .audio):
            return true
        case .act, .gat, .gnd, .rsm, .rsw, .spr, .str:
            return true
        default:
            return false
        }
    }
}
