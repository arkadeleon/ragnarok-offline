//
//  GRFArchive.swift
//  GRF
//
//  Created by Leon Li on 2020/8/17.
//

import BinaryIO
import Foundation

#if canImport(OSLog)
import OSLog
#endif

public actor GRFArchive {
    nonisolated public let url: URL

    #if canImport(OSLog)
    private let logger = Logger(subsystem: "swift-grf", category: "grf")
    #endif

    private lazy var grf: GRF? = {
        #if canImport(OSLog)
        let beginTime = CFAbsoluteTimeGetCurrent()
        logger.info("GRF: Begin loading")
        #endif

        let grf = try? GRF(url: url)

        #if canImport(OSLog)
        let endTime = CFAbsoluteTimeGetCurrent()
        logger.info("GRF: End loading (\(endTime - beginTime)s)")
        #endif

        return grf
    }()

    private lazy var directories: Set<GRFPath> = {
        guard let grf else {
            return []
        }

        #if canImport(OSLog)
        let beginTime = CFAbsoluteTimeGetCurrent()
        logger.info("GRF: Begin loading directories")
        #endif

        var directories = Set(grf.table.entries.map({ $0.path.parent }))
        for directory in directories {
            var parent = directory
            repeat {
                parent = parent.parent
                directories.insert(parent)
            } while !parent.string.isEmpty
        }

        #if canImport(OSLog)
        let endTime = CFAbsoluteTimeGetCurrent()
        logger.info("GRF: End loading directories (\(endTime - beginTime)s)")
        #endif

        return directories
    }()

    private lazy var entriesByPath: [String : GRF.Entry] = {
        guard let grf else {
            return [:]
        }

        #if canImport(OSLog)
        let beginTime = CFAbsoluteTimeGetCurrent()
        logger.info("GRF: Begin loading entries")
        #endif

        let entries = Dictionary(
            grf.table.entries.map({ ($0.path.string.uppercased(), $0) }),
            uniquingKeysWith: { (first, _) in first }
        )

        #if canImport(OSLog)
        let endTime = CFAbsoluteTimeGetCurrent()
        logger.info("GRF: End loading entries (\(endTime - beginTime)s)")
        #endif

        return entries
    }()

    public init(url: URL) {
        self.url = url
    }

    public func directory(at path: GRFPath) -> GRFDirectoryNode? {
        guard let grf else {
            return nil
        }

        #if canImport(OSLog)
        let beginTime = CFAbsoluteTimeGetCurrent()
        logger.info("GRF: Begin loading directory at \(path.string)")
        #endif

        let subdirectories = directories
            .filter { $0.parent == path }
            .map(GRFSubdirectoryNode.init)
            .sorted(using: KeyPathComparator(\.path.string))

        let entries = grf.table.entries
            .filter { $0.path.parent == path }
            .map(GRFEntryNode.init)
            .sorted(using: KeyPathComparator(\.path.string))

        #if canImport(OSLog)
        let endTime = CFAbsoluteTimeGetCurrent()
        logger.info("GRF: End loading directory at \(path.string) (\(endTime - beginTime)s)")
        #endif

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
