//
//  GRFArchive.swift
//  GRF
//
//  Created by Leon Li on 2020/8/17.
//

import BinaryIO
import Foundation

@globalActor
public actor GRFActor {
    public static let shared = GRFActor()
}

@GRFActor
public class GRFArchive {
    nonisolated public let url: URL

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

    nonisolated public init(url: URL) {
        self.url = url
    }

    public func directoryNode(at path: GRFPath) -> GRFNode? {
        directories.contains(path) ? GRFNode(path: path, isDirectory: true) : nil
    }

    public func contentsOfDirectoryNode(at path: GRFPath) -> [GRFNode] {
        guard let grf else {
            return []
        }

        #if canImport(OSLog)
        let beginTime = CFAbsoluteTimeGetCurrent()
        logger.info("GRF: Begin loading directory at \(path.string)")
        #endif

        let subdirectoryNodes = directories
            .filter({ $0.parent == path })
            .map({ GRFNode(path: $0, isDirectory: true) })
            .sorted(using: KeyPathComparator(\.path.string))

        let entryNodes = grf.table.entries
            .filter({ $0.path.parent == path })
            .map({ GRFNode(path: $0.path, isDirectory: false) })
            .sorted(using: KeyPathComparator(\.path.string))

        #if canImport(OSLog)
        let endTime = CFAbsoluteTimeGetCurrent()
        logger.info("GRF: End loading directory at \(path.string) (\(endTime - beginTime)s)")
        #endif

        return subdirectoryNodes + entryNodes
    }

    public func entryNode(at path: GRFPath) -> GRFNode? {
        entriesByPath[path.string.uppercased()].flatMap({ GRFNode(path: $0.path, isDirectory: false) })
    }

    public func sizeOfEntryNode(at path: GRFPath) -> Int? {
        entriesByPath[path.string.uppercased()].flatMap({ Int($0.size) })
    }

    public func contentsOfEntryNode(at path: GRFPath) throws -> Data {
        guard let entry = entriesByPath[path.string.uppercased()] else {
            throw GRFError.invalidEntryPath(path.string)
        }

        guard let stream = FileStream(forReadingFrom: url) else {
            throw GRFError.invalidURL(url)
        }

        defer {
            stream.close()
        }

        let data = try entry.data(from: stream)
        return data
    }
}
