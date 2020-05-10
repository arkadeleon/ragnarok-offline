//
//  Document.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/8.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

enum DocumentSource {

    case url(URL)

    case entryInArchive(ArchiveEntry, Archive)

    fileprivate var name: String {
        switch self {
        case .url(let url):
            return url.lastPathComponent
        case .entryInArchive(let entry, _):
            return entry.lastPathComponent
        }
    }

    fileprivate var fileType: String {
        switch self {
        case .url(let url):
            return url.pathExtension
        case .entryInArchive(let entry, _):
            return entry.pathExtension
        }
    }

    fileprivate func data() throws -> Data {
        switch self {
        case .url(let url):
            return try Data(contentsOf: url)
        case .entryInArchive(let entry, let archive):
            return try archive.contents(of: entry)
        }
    }
}

class DocumentContents {

    private let source: DocumentSource

    init(source: DocumentSource) {
        self.source = source
    }

    func data() throws -> Data {
        return try source.data()
    }
}

class Document: NSObject {

    let source: DocumentSource
    let name: String
    let fileType: String

    init(source: DocumentSource) {
        self.source = source
        self.name = source.name
        self.fileType = source.fileType
    }

    func open(completionHandler: ((Bool) -> Void)? = nil) {
        DispatchQueue.global().async {
            let contents = DocumentContents(source: self.source)
            do {
                try self.load(from: contents)
                DispatchQueue.main.async {
                    completionHandler?(true)
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler?(false)
                }
            }
        }
    }

    func load(from contents: DocumentContents) throws {

    }

    func close(completionHandler: ((Bool) -> Void)? = nil) {

    }
}
