//
//  File.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/18.
//

import Foundation
import ROFileFormats

public enum File {
    case directory(URL)
    case regularFile(URL)
    case grf(GRFReference)
    case grfDirectory(GRFReference, GRFPath)
    case grfEntry(GRFReference, GRFPath)

    public var url: URL {
        switch self {
        case .directory(let url):
            return url
        case .regularFile(let url):
            return url
        case .grf(let grf):
            return grf.url
        case .grfDirectory(let grf, let directory):
            return grf.url.appending(queryItems: [
                URLQueryItem(name: "path", value: directory.string)
            ])
        case .grfEntry(let grf, let path):
            return grf.url.appending(queryItems: [
                URLQueryItem(name: "path", value: path.string)
            ])
        }
    }

    public var name: String {
        switch self {
        case .directory(let url):
            return url.lastPathComponent
        case .regularFile(let url):
            return url.lastPathComponent
        case .grf(let grf):
            return grf.url.lastPathComponent
        case .grfDirectory(_, let directory):
            return directory.lastComponent
        case .grfEntry(_, let path):
            return path.lastComponent
        }
    }

    public var type: FileType {
        switch self {
        case .directory:
            .directory
        case .regularFile(let url):
            FileType(url.pathExtension)
        case .grf:
            .grf
        case .grfDirectory:
            .directory
        case .grfEntry(_, let path):
            FileType(path.extension)
        }
    }

    public var size: Int64 {
        switch self {
        case .directory:
            return 0
        case .regularFile(let url):
            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
            return Int64(size)
        case .grf(let grf):
            let size = (try? grf.url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
            return Int64(size)
        case .grfDirectory:
            return 0
        case .grfEntry(let grf, let path):
            let size = grf.entry(at: path)?.size ?? 0
            return Int64(size)
        }
    }

    public func contents() -> Data? {
        switch self {
        case .directory:
            return nil
        case .regularFile(let url):
            return try? Data(contentsOf: url)
        case .grf:
            return nil
        case .grfDirectory:
            return nil
        case .grfEntry(let grf, let path):
            return try? grf.contentsOfEntry(at: path)
        }
    }

    public func files() -> [File] {
        switch self {
        case .directory(let url):
            let urls = (try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])) ?? []
            let files = urls.map({ $0.resolvingSymlinksInPath() }).map { url -> File in
                switch url.pathExtension.lowercased() {
                case "grf":
                    let grf = GRFReference(url: url)
                    return .grf(grf)
                default:
                    let values = try? url.resourceValues(forKeys: [.isDirectoryKey])
                    if values?.isDirectory == true {
                        return .directory(url)
                    } else {
                        return .regularFile(url)
                    }
                }
            }
            return files
        case .regularFile:
            return []
        case .grf(let grf):
            let file = File.grfDirectory(grf, GRFPath(components: ["data"]))
            return file.files()
        case .grfDirectory(let grf, let directory):
            var files: [File] = []
            let (directories, entries) = grf.contentsOfDirectory(directory)
            for directory in directories {
                let file = File.grfDirectory(grf, directory)
                files.append(file)
            }
            for entry in entries {
                let file = File.grfEntry(grf, entry.path)
                files.append(file)
            }
            return files
        case .grfEntry:
            return []
        }
    }
}
