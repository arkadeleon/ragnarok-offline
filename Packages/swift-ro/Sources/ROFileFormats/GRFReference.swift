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
        let beginTime = CFAbsoluteTimeGetCurrent()

        let grf = try? GRF(url: url)

        let endTime = CFAbsoluteTimeGetCurrent()
        logger.info("Load GRF (\(endTime - beginTime)s)")

        return grf
    }()

    private lazy var directories: Set<GRFPath> = {
        guard let grf else {
            return []
        }

        let beginTime = CFAbsoluteTimeGetCurrent()

        var directories = Set(grf.table.entries.map({ $0.path.parent }))
        for directory in directories {
            var parent = directory
            repeat {
                parent = parent.parent
                directories.insert(parent)
            } while !parent.string.isEmpty
        }

        let endTime = CFAbsoluteTimeGetCurrent()
        logger.info("Load GRF directories (\(endTime - beginTime)s)")

        return directories
    }()

    private lazy var entriesByPath: [String : GRF.Entry] = {
        guard let grf else {
            return [:]
        }

        let beginTime = CFAbsoluteTimeGetCurrent()

        let entries = Dictionary(
            grf.table.entries.map({ ($0.path.string.uppercased(), $0) }),
            uniquingKeysWith: { (first, _) in first }
        )

        let endTime = CFAbsoluteTimeGetCurrent()
        logger.info("Load GRF entries (\(endTime - beginTime)s)")

        return entries
    }()

    public init(url: URL) {
        self.url = url
    }

    public func contentsOfDirectory(_ directory: GRFPath) -> (directories: [GRFPath], entries: [GRF.Entry]) {
        guard let grf else {
            return ([], [])
        }

        let beginTime = CFAbsoluteTimeGetCurrent()

        let directories = directories
            .filter { $0.parent == directory }
            .sorted(using: KeyPathComparator(\.string))

        let entries = grf.table.entries
            .filter { $0.path.parent == directory }
            .sorted(using: KeyPathComparator(\.path.string))

        let endTime = CFAbsoluteTimeGetCurrent()
        logger.info("Load contents of directory at \(directory.string) (\(endTime - beginTime)s)")

        return (directories, entries)
    }

    public func entry(at path: GRFPath) -> GRF.Entry? {
        entriesByPath[path.string.uppercased()]
    }

    public func contentsOfEntry(at path: GRFPath) throws -> Data {
        guard let entry = entry(at: path) else {
            throw GRFError.invalidPath(path.string)
        }

        let stream = try FileStream(url: url)
        defer {
            stream.close()
        }

        let data = try entry.data(from: stream)
        return data
    }
}
