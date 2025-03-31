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

    private lazy var grf: GRF? = {
        metric.beginMeasuring("Load GRF")

        let grf = try? GRF(url: url)

        metric.endMeasuring("Load GRF")

        return grf
    }()

    private lazy var directories: Set<GRFPath> = {
        guard let grf else {
            return []
        }

        metric.beginMeasuring("Load GRF directories")

        var directories = Set(grf.table.entries.map({ $0.path.parent }))
        for directory in directories {
            var parent = directory
            repeat {
                parent = parent.parent
                directories.insert(parent)
            } while !parent.string.isEmpty
        }

        metric.endMeasuring("Load GRF directories")

        return directories
    }()

    private lazy var entriesByPath: [String : GRF.Entry] = {
        guard let grf else {
            return [:]
        }

        metric.beginMeasuring("Load GRF entries")

        let entries = Dictionary(
            grf.table.entries.map({ ($0.path.string.uppercased(), $0) }),
            uniquingKeysWith: { (first, _) in first }
        )

        metric.endMeasuring("Load GRF entries")

        return entries
    }()

    public init(url: URL) {
        self.url = url
    }

    public func contentsOfDirectory(_ directory: GRFPath) -> (directories: [GRFPath], entries: [GRF.Entry]) {
        guard let grf else {
            return ([], [])
        }

        let directories = directories
            .filter { $0.parent == directory }
            .sorted(using: KeyPathComparator(\.string))

        let entries = grf.table.entries
            .filter { $0.path.parent == directory }
            .sorted(using: KeyPathComparator(\.path.string))

        return (directories, entries)
    }

    public func entry(at path: GRFPath) -> GRF.Entry? {
        entriesByPath[path.string.uppercased()]
    }

    public func contentsOfEntry(at path: GRFPath) throws -> Data {
        guard let entry = entry(at: path) else {
            throw GRFError.invalidEntryPath(path.string)
        }

        guard let stream = FileStream(url: url) else {
            throw GRFError.invalidURL(url)
        }

        defer {
            stream.close()
        }

        let data = try entry.data(from: stream)
        return data
    }
}
