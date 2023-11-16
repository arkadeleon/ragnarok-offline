//
//  File.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/18.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import UIKit

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
            let path = directory.string.replacing("\\", with: "/")
            return grf.url.appendingPathComponent(path)
        case .grfEntry(let grf, let entry):
            let path = entry.path.string.replacing("\\", with: "/")
            return grf.url.appendingPathComponent(path)
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

    func pasteFromPasteboard(_ pasteboard: FilePasteboard) -> File? {
        guard let sourceFile = pasteboard.file else {
            return nil
        }

        guard case .url(let url) = self else {
            return nil
        }

        let destinationFile = File.url(url.appending(path: sourceFile.name))
        switch sourceFile {
        case .url:
            do {
                try FileManager.default.copyItem(at: sourceFile.url, to: destinationFile.url)
                return destinationFile
            } catch {
                return nil
            }
        case .grf:
            return nil
        case .grfDirectory:
            return nil
        case .grfEntry(let grf, let entry):
            guard let contents = try? grf.contentsOfEntry(entry) else {
                return nil
            }
            do {
                try contents.write(to: destinationFile.url)
                return destinationFile
            } catch {
                return nil
            }
        }
    }
}

extension File: Identifiable {
    var id: URL {
        url
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

    static func == (lhs: File, rhs: File) -> Bool {
        lhs.id == rhs.id
    }
}
