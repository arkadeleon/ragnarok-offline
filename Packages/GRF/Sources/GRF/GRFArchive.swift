//
//  GRFArchive.swift
//  GRF
//
//  Created by Leon Li on 2020/8/17.
//

import BinaryIO
import Foundation

public actor GRFArchive {
    nonisolated public let url: URL

    private lazy var grf: GRF? = {
        #if !os(Linux)
        let beginTime = CFAbsoluteTimeGetCurrent()
        #endif

        let grf = try? GRF(url: url)

        #if !os(Linux)
        let endTime = CFAbsoluteTimeGetCurrent()
        logger.info("GRF: Load (\(endTime - beginTime)s)")
        #endif

        return grf
    }()

    private lazy var entriesByPath: [String : GRF.Entry] = {
        guard let grf else {
            return [:]
        }

        #if !os(Linux)
        let beginTime = CFAbsoluteTimeGetCurrent()
        #endif

        let entries = Dictionary(
            grf.table.entries.map({ ($0.path.string.uppercased(), $0) }),
            uniquingKeysWith: { (first, _) in first }
        )

        #if !os(Linux)
        let endTime = CFAbsoluteTimeGetCurrent()
        logger.info("GRF: Load entries (\(endTime - beginTime)s)")
        #endif

        return entries
    }()

    private lazy var directories: Set<GRFPathReference> = {
        guard let grf else {
            return []
        }

        #if !os(Linux)
        let beginTime = CFAbsoluteTimeGetCurrent()
        #endif

        var directories = Set(grf.table.entries.map({ $0.path.parent }))
        for directory in directories {
            var parent = directory
            repeat {
                parent = parent.parent
                directories.insert(parent)
            } while !parent.string.isEmpty
        }

        #if !os(Linux)
        let endTime = CFAbsoluteTimeGetCurrent()
        logger.info("GRF: Load directories (\(endTime - beginTime)s)")
        #endif

        return directories
    }()

    public init(url: URL) {
        self.url = url
    }

    public func directoryNode(at path: GRFPath) -> GRFNode? {
        let path = GRFPathReference(path: path)

        if directories.contains(path) {
            return GRFNode(path: path, isDirectory: true)
        } else {
            return nil
        }
    }

    public func childCountOfDirectoryNode(at path: GRFPath) -> Int {
        guard let grf else {
            return 0
        }

        let path = GRFPathReference(path: path)

        #if !os(Linux)
        let beginTime = CFAbsoluteTimeGetCurrent()
        #endif

        let subdirectoryNodeCount = directories
            .count(where: { $0.parent == path })

        let entryNodeCount = grf.table.entries
            .count(where: { $0.path.parent == path })

        #if !os(Linux)
        let endTime = CFAbsoluteTimeGetCurrent()
        logger.info("GRF: Load child count of directory node at \(path.string) (\(endTime - beginTime)s)")
        #endif

        return subdirectoryNodeCount + entryNodeCount
    }

    public func childrenOfDirectoryNode(at path: GRFPath) -> [GRFNode] {
        guard let grf else {
            return []
        }

        let path = GRFPathReference(path: path)

        #if !os(Linux)
        let beginTime = CFAbsoluteTimeGetCurrent()
        #endif

        let subdirectoryNodes = directories
            .filter({ $0.parent == path })
            .map({ GRFNode(path: $0, isDirectory: true) })
            .sorted(using: KeyPathComparator(\.path.string))

        let entryNodes = grf.table.entries
            .filter({ $0.path.parent == path })
            .map({ GRFNode(path: $0.path, isDirectory: false) })
            .sorted(using: KeyPathComparator(\.path.string))

        #if !os(Linux)
        let endTime = CFAbsoluteTimeGetCurrent()
        logger.info("GRF: Load children of directory node at \(path.string) (\(endTime - beginTime)s)")
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
