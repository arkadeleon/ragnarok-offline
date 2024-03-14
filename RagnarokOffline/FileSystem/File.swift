//
//  File.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/18.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import Foundation

enum File {
    case directory(URL)
    case regularFile(URL)
    case grf(GRFWrapper)
    case grfDirectory(GRFWrapper, GRF.Path)
    case grfEntry(GRFWrapper, GRF.Path)

    var url: URL {
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

    var name: String {
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

    var size: Int? {
        switch self {
        case .directory:
            return nil
        case .regularFile(let url):
            let values = try? url.resourceValues(forKeys: [.fileSizeKey])
            return values?.fileSize
        case .grf(let grf):
            let values = try? grf.url.resourceValues(forKeys: [.fileSizeKey])
            return values?.fileSize
        case .grfDirectory:
            return nil
        case .grfEntry(let grf, let path):
            let entry = grf.entry(at: path)
            return entry.flatMap({ Int($0.size) })
        }
    }

    func contents() -> Data? {
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

    func files() -> [File] {
        switch self {
        case .directory(let url):
            let urls = (try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])) ?? []
            let files = urls.map({ $0.resolvingSymlinksInPath() }).map { url -> File in
                switch url.pathExtension.lowercased() {
                case "grf":
                    let grf = GRFWrapper(url: url)
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
            let file = File.grfDirectory(grf, GRF.Path(string: "data"))
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

extension File: Comparable {
    static func < (lhs: File, rhs: File) -> Bool {
        let lhsRank = switch lhs {
        case .directory, .grfDirectory: 0
        default: 1
        }

        let rhsRank = switch rhs {
        case .directory, .grfDirectory: 0
        default: 1
        }

        if lhsRank == rhsRank {
            return lhs.name.lowercased() < rhs.name.lowercased()
        } else {
            return lhsRank < rhsRank
        }
    }
}

extension File: Identifiable {
    var id: URL {
        url
    }
}

extension File: Hashable {
    func hash(into hasher: inout Hasher) {
        url.hash(into: &hasher)
    }
}

extension File: Equatable {
    static func == (lhs: File, rhs: File) -> Bool {
        lhs.url == rhs.url
    }
}
