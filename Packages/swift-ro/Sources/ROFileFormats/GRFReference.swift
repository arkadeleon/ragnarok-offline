//
//  GRFReference.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/8/17.
//

import Foundation
import ROCore

public class GRFReference {
    public let url: URL

    private lazy var grf = {
        let start = Date()
        print("Start loading GRF: \(url)")

        let grf = try? GRF(url: url)

        print("Finish loading GRF (\(Date().timeIntervalSince(start))")

        return grf
    }()

    private lazy var directories: Set<GRF.Path> = {
        guard let grf else {
            return []
        }

        let start = Date()
        print("Start loading directories: \(url)")

        var directories = Set(grf.table.entries.map({ $0.path.parent }))
        for directory in directories {
            var parent = directory
            repeat {
                parent = parent.parent
                directories.insert(parent)
            } while !parent.string.isEmpty
        }

        print("Finish loading directories (\(Date().timeIntervalSince(start))")

        return directories
    }()

    private lazy var entriesByPath: [String : GRF.Entry] = {
        guard let grf else {
            return [:]
        }

        let start = Date()
        print("Start loading entries: \(url)")

        let entries = Dictionary(grf.table.entries.map({ ($0.path.string.uppercased(), $0) }), uniquingKeysWith: { (first, _) in first })

        print("Finish loading entries (\(Date().timeIntervalSince(start))")

        return entries
    }()

    public init(url: URL) {
        self.url = url
    }

    public func contentsOfDirectory(_ directory: GRF.Path) -> ([GRF.Path], [GRF.Entry]) {
        guard let grf else {
            return ([], [])
        }

        let start = Date()
        print("Start loading contents of directory: \(directory.string)")

        let directories = directories
            .filter { $0.parent == directory }
            .sorted(using: KeyPathComparator(\.string))

        let entries = grf.table.entries
            .filter { $0.path.parent == directory }
            .sorted(using: KeyPathComparator(\.path.string))

        print("Finish loading contents of directory (\(Date().timeIntervalSince(start))")

        return (directories, entries)
    }

    public func entry(at path: GRF.Path) -> GRF.Entry? {
        entriesByPath[path.string.uppercased()]
    }

    public func contentsOfEntry(at path: GRF.Path) throws -> Data {
        guard let entry = entry(at: path) else {
            throw GRFError.invalidPath(path)
        }

        let stream = try FileStream(url: url)
        defer {
            stream.close()
        }

        let data = try entry.data(from: stream)
        return data
    }
}
