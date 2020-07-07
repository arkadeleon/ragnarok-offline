//
//  Document.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/8.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

enum DocumentError: Error {

    case invalidSource
    case invalidContents
}

enum DocumentSource {

    case url(URL)

    case entryInArchive(GRFArchive, String)

    var name: String {
        switch self {
        case .url(let url):
            return url.lastPathComponent
        case .entryInArchive(_, let entryName):
            let lastPathComponent = entryName.split(separator: "\\").last
            return String(lastPathComponent ?? "")
        }
    }

    var fileType: String {
        switch self {
        case .url(let url):
            return url.pathExtension
        case .entryInArchive(_, let entryName):
            let pathExtension = entryName.split(separator: "\\").last?.split(separator: ".").last
            return String(pathExtension ?? "")
        }
    }

    func data() throws -> Data {
        switch self {
        case .url(let url):
            return try Data(contentsOf: url)
        case .entryInArchive(let archive, let entryName):
            guard let entry = archive.entry(forName: entryName) else {
                return Data()
            }
            return try archive.contents(of: entry)
        }
    }
}

protocol Document {

    associatedtype Source

    associatedtype Contents

    var source: Source { get }

    var name: String { get }

    init(source: Source)

    func load() -> Result<Contents, DocumentError>
}
