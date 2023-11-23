//
//  GRFWrapper.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/8/17.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

class GRFWrapper {
    let url: URL

    private lazy var grf = {
        let start = Date()
        print("Start loading GRF: \(url)")

        let grf = try? GRF(url: url)

        print("Finish loading GRF (\(Date().timeIntervalSince(start))")

        return grf
    }()

    init(url: URL) {
        self.url = url
    }

    func contentsOfDirectory(_ directory: GRF.Path) -> ([GRF.Path], [GRF.Entry]) {
        guard let grf else {
            return ([], [])
        }

        let start = Date()
        print("Start loading contents of directory: \(directory.string)")

        let directories = grf.table.directories
            .filter { $0.parent == directory }
            .sorted()

        let entries = grf.table.entries
            .filter { $0.path.parent == directory }
            .sorted()

        print("Finish loading contents of directory (\(Date().timeIntervalSince(start))")

        return (directories, entries)
    }

    func contentsOfEntry(_ entry: GRF.Entry) throws -> Data {
        let stream = try FileStream(url: url)
        let reader = BinaryReader(stream: stream)

        defer {
            reader.close()
        }

        let data = try entry.data(from: reader)

        return data
    }

    func contentsOfEntry(at path: GRF.Path) throws -> Data {
        guard let grf else {
            throw DocumentError.invalidSource
        }

        guard let entry = grf.table.entries.first(where: { $0.path == path }) else {
            throw DocumentError.invalidSource
        }

        return try contentsOfEntry(entry)
    }
}
