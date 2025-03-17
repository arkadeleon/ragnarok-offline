//
//  File.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/24.
//

import Foundation
import Observation
import ROFileFormats

enum FileNode {
    case directory(URL)
    case regularFile(URL)
    case grf(GRFReference)
    case grfDirectory(GRFReference, GRFPath)
    case grfEntry(GRFReference, GRFPath)
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
        case .grf(let grf):
            grf.url
        case .grfDirectory(let grf, let directory):
            grf.url.appending(queryItems: [
                URLQueryItem(name: "path", value: directory.string)
            ])
        case .grfEntry(let grf, let path):
            grf.url.appending(queryItems: [
                URLQueryItem(name: "path", value: path.string)
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
        case .grf(let grf):
            grf.url.lastPathComponent
        case .grfDirectory(_, let directory):
            directory.lastComponent
        case .grfEntry(_, let path):
            path.lastComponent
        }
    }()

    @ObservationIgnored
    lazy var `extension`: String = {
        switch node {
        case .directory(let url):
            url.pathExtension
        case .regularFile(let url):
            url.pathExtension
        case .grf(let grf):
            grf.url.pathExtension
        case .grfDirectory(_, let directory):
            directory.extension
        case .grfEntry(_, let path):
            path.extension
        }
    }()

    var type: FileType {
        switch node {
        case .directory:
            .directory
        case .regularFile(let url):
            FileType(self.extension)
        case .grf:
            .grf
        case .grfDirectory:
            .directory
        case .grfEntry(_, let path):
            FileType(self.extension)
        }
    }

    var id: URL {
        url
    }

    init(node: FileNode) {
        self.node = node
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
        case .grf(let grf):
            let size = (try? grf.url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
            return size
        case .grfDirectory:
            return 0
        case .grfEntry(let grf, let path):
            let size = grf.entry(at: path)?.size ?? 0
            return Int(size)
        }
    }

    func contents() async -> Data? {
        switch node {
        case .directory:
            nil
        case .regularFile(let url):
            try? Data(contentsOf: url)
        case .grf:
            nil
        case .grfDirectory:
            nil
        case .grfEntry(let grf, let path):
            try? grf.contentsOfEntry(at: path)
        }
    }

    func files() async -> [File] {
        switch node {
        case .directory(let url):
            let urls = (try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])) ?? []
            let files = urls.map({ $0.resolvingSymlinksInPath() }).map { url -> File in
                switch url.pathExtension.lowercased() {
                case "grf":
                    let grf = GRFReference(url: url)
                    return File(node: .grf(grf))
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
        case .grf(let grf):
            let path = GRFPath(components: ["data"])
            let file = File(node: .grfDirectory(grf, path))
            return await file.files()
        case .grfDirectory(let grf, let directory):
            var files: [File] = []
            let (directories, entries) = grf.contentsOfDirectory(directory)
            for directory in directories {
                let file = File(node: .grfDirectory(grf, directory))
                files.append(file)
            }
            for entry in entries {
                let file = File(node: .grfEntry(grf, entry.path))
                files.append(file)
            }
            return files.sorted()
        case .grfEntry:
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
        case .grf(let grf):
            let path = GRFPath(components: ["data"])
            let file = File(node: .grfDirectory(grf, path))
            return await file.fileCount()
        case .grfDirectory(let grf, let directory):
            let (directories, entries) = grf.contentsOfDirectory(directory)
            return directories.count + entries.count
        case .grfEntry:
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
    var iconName: String {
        switch type {
        case .directory:
            "folder.fill"
        case .text, .lua, .lub:
            "doc.text"
        case .image, .ebm, .pal:
            "photo"
        case .audio:
            "waveform.circle"
        case .grf:
            "doc.zipper"
        case .act:
            "livephoto"
        case .gat:
            "square.grid.3x3.middle.filled"
        case .gnd:
            "mountain.2"
        case .imf:
            "square.3.layers.3d"
        case .rsm:
            "square.stack.3d.up"
        case .rsw:
            "map"
        case .spr:
            "photo.stack"
        case .str:
            "sparkles.rectangle.stack"
        case .unknown:
            "doc"
        }
    }
}

extension File {
    var canPreview: Bool {
        switch type {
        case .text, .lua, .lub:
            true
        case .image, .ebm, .pal:
            true
        case .audio:
            true
        case .act, .gat, .gnd, .rsm, .rsw, .spr, .str:
            true
        default:
            false
        }
    }

    var canCopy: Bool {
        switch node {
        case .regularFile, .grf, .grfEntry:
            true
        default:
            false
        }
    }

    var canPaste: Bool {
        switch node {
        case .directory where FilePasteboard.shared.hasFile:
            true
        default: 
            false
        }
    }

    var canDelete: Bool {
        switch node {
        case .regularFile, .grf:
            true
        default:
            false
        }
    }
}
