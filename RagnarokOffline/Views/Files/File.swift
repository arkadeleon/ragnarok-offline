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

    var `extension`: String {
        (name as NSString).pathExtension
    }

    func contents() -> Data? {
        guard let type else {
            return nil
        }

        guard !type.conforms(to: .directory), !type.conforms(to: .archive) else {
            return nil
        }

        switch self {
        case .url(let url):
            return try? Data(contentsOf: url)
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
            guard let type, type.conforms(to: .directory) else {
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
        let lhsRank = lhs.type?.conforms(to: .directory) == true ? 0 : 1
        let rhsRank = rhs.type?.conforms(to: .directory) == true ? 0 : 1

        if lhsRank == rhsRank {
            return lhs.name.lowercased() < rhs.name.lowercased()
        } else {
            return lhsRank < rhsRank
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
        url.hash(into: &hasher)
    }
}
