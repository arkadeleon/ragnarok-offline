//
//  File.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/18.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import Foundation

enum File {
    case url(URL)
    case grf(GRFWrapper)
    case grfDirectory(GRFWrapper, GRF.Path)
    case grfEntry(GRFWrapper, GRF.Entry)

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
        case .grfEntry(_, let entry):
            let fileType = FileType(rawValue: String(entry.path.extension))
            return fileType
        }
    }

    var url: URL {
        switch self {
        case .url(let url):
            return url
        case .grf(let grf):
            return grf.url
        case .grfDirectory(let grf, let directory):
            return grf.url.appending(queryItems: [
                URLQueryItem(name: "path", value: directory.string)
            ])
        case .grfEntry(let grf, let entry):
            return grf.url.appending(queryItems: [
                URLQueryItem(name: "path", value: entry.path.string)
            ])
        }
    }

    var name: String {
        switch self {
        case .url(let url):
            return url.lastPathComponent
        case .grf(let grf):
            return grf.url.lastPathComponent
        case .grfDirectory(_, let directory):
            return directory.lastComponent
        case .grfEntry(_, let entry):
            return entry.path.lastComponent
        }
    }

    var hasInfo: Bool {
        switch contentType {
        case .act, .gat, .gnd, .rsm, .rsw, .spr, .str:
            true
        default:
            false
        }
    }

    var info: Encodable? {
        switch contentType {
        case .act:
            guard let data = contents() else {
                return nil
            }
            let act = try? ACT(data: data)
            return act
        case .gat:
            guard let data = contents() else {
                return nil
            }
            let gat = try? GAT(data: data)
            return gat
        case .gnd:
            guard let data = contents() else {
                return nil
            }
            let gnd = try? GND(data: data)
            return gnd
        case .rsm:
            guard let data = contents() else {
                return nil
            }
            let rsm = try? RSM(data: data)
            return rsm
        case .rsw:
            guard let data = contents() else {
                return nil
            }
            let rsw = try? RSW(data: data)
            return rsw
        case .spr:
            guard let data = contents() else {
                return nil
            }
            let spr = try? SPR(data: data)
            return spr
        case .str:
            guard let data = contents() else {
                return nil
            }
            let str = try? STR(data: data)
            return str
        default:
            return nil
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
        case .grfEntry(let grf, let entry):
            return try? grf.contentsOfEntry(entry)
        }
    }

    func files() -> [File] {
        var files: [File] = []

        switch self {
        case .url(let url):
            guard isDirectory else {
                break
            }
            guard let urls = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []) else {
                break
            }
            files = urls.map({ $0.resolvingSymlinksInPath() }).map { url -> File in
                switch url.pathExtension.lowercased() {
                case "grf":
                    let grf = GRFWrapper(url: url)
                    return .grf(grf)
                default:
                    return .url(url)
                }
            }
        case .grf(let grf):
            let file = File.grfDirectory(grf, GRF.Path(string: "data"))
            files = file.files()
        case .grfDirectory(let grf, let directory):
            let (directories, entries) = grf.contentsOfDirectory(directory)
            for directory in directories {
                let file = File.grfDirectory(grf, directory)
                files.append(file)
            }
            for entry in entries {
                let file = File.grfEntry(grf, entry)
                files.append(file)
            }
        case .grfEntry:
            break
        }

        return files
    }
}

extension File: Comparable {
    static func < (lhs: File, rhs: File) -> Bool {
        if lhs.isDirectory == rhs.isDirectory {
            return lhs.name.lowercased() < rhs.name.lowercased()
        } else {
            let lhsRank = lhs.isDirectory ? 0 : 1
            let rhsRank = rhs.isDirectory ? 0 : 1
            return lhsRank < rhsRank
        }
    }
}

extension File: Equatable {
    static func == (lhs: File, rhs: File) -> Bool {
        lhs.id == rhs.id
    }
}

extension File: Hashable {
    func hash(into hasher: inout Hasher) {
        url.hash(into: &hasher)
    }
}

extension File: Identifiable {
    var id: URL {
        url
    }
}