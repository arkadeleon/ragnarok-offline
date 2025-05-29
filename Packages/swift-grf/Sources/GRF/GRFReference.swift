//
//  GRFReference.swift
//  GRF
//
//  Created by Leon Li on 2020/8/17.
//

import BinaryIO
import Foundation

public class GRFReference {
    public let url: URL

    private lazy var grf: GRF? = {
        let beginTime = CFAbsoluteTimeGetCurrent()
        logger.info("GRF: Begin loading")

        let grf = try? GRF(url: url)

        let endTime = CFAbsoluteTimeGetCurrent()
        logger.info("GRF: End loading (\(endTime - beginTime)s)")

        return grf
    }()

    private lazy var directories: Set<GRFPath> = {
        guard let grf else {
            return []
        }

        let beginTime = CFAbsoluteTimeGetCurrent()
        logger.info("GRF: Begin loading directories")

        var directories = Set(grf.table.entries.map({ $0.path.parent }))
        for directory in directories {
            var parent = directory
            repeat {
                parent = parent.parent
                directories.insert(parent)
            } while !parent.string.isEmpty
        }

        let endTime = CFAbsoluteTimeGetCurrent()
        logger.info("GRF: End loading directories (\(endTime - beginTime)s)")

        return directories
    }()

    private lazy var entriesByPath: [String : GRF.Entry] = {
        guard let grf else {
            return [:]
        }

        let beginTime = CFAbsoluteTimeGetCurrent()
        logger.info("GRF: Begin loading entries")

        let entries = Dictionary(
            grf.table.entries.map({ ($0.path.string.uppercased(), $0) }),
            uniquingKeysWith: { (first, _) in first }
        )

        let endTime = CFAbsoluteTimeGetCurrent()
        logger.info("GRF: End loading entries (\(endTime - beginTime)s)")

        return entries
    }()

    public init(url: URL) {
        self.url = url
    }

    public func directory(at path: GRFPath) -> GRFDirectoryNode? {
        guard let grf else {
            return nil
        }

        let beginTime = CFAbsoluteTimeGetCurrent()
        logger.info("GRF: Begin loading directory at \(path.string)")

        let subdirectories = directories
            .filter { $0.parent == path }
            .map(GRFSubdirectoryNode.init)
            .sorted(using: KeyPathComparator(\.path.string))

        let entries = grf.table.entries
            .filter { $0.path.parent == path }
            .map(GRFEntryNode.init)
            .sorted(using: KeyPathComparator(\.path.string))

        let endTime = CFAbsoluteTimeGetCurrent()
        logger.info("GRF: End loading directory at \(path.string) (\(endTime - beginTime)s)")

        return GRFDirectoryNode(subdirectories: subdirectories, entries: entries)
    }

    public func entry(at path: GRFPath) -> GRFEntryNode? {
        entriesByPath[path.string.uppercased()].flatMap(GRFEntryNode.init)
    }

    public func contentsOfEntry(at path: GRFPath) throws -> Data {
        guard let entry = entriesByPath[path.string.uppercased()] else {
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
