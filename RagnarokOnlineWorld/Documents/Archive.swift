//
//  Archive.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/8.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

protocol Archive {

    var entries: [ArchiveEntry] { get }

    func contents(of entry: ArchiveEntry) throws -> Data
}

protocol ArchiveEntry {

    var path: String { get }

    var lastPathComponent: String { get }

    var pathExtension: String { get }
}
