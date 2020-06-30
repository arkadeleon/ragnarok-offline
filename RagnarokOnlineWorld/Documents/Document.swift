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

    fileprivate var name: String {
        switch self {
        case .url(let url):
            return url.lastPathComponent
        case .entryInArchive(_, let entryName):
            let lastPathComponent = entryName.split(separator: "\\").last
            return String(lastPathComponent ?? "")
        }
    }

    fileprivate var fileType: String {
        switch self {
        case .url(let url):
            return url.pathExtension
        case .entryInArchive(_, let entryName):
            let pathExtension = entryName.split(separator: "\\").last?.split(separator: ".").last
            return String(pathExtension ?? "")
        }
    }

    fileprivate func data() throws -> Data {
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

class Document<Contents>: NSObject {

    let source: DocumentSource
    let name: String
    let fileType: String

    init(source: DocumentSource) {
        self.source = source
        self.name = source.name
        self.fileType = source.fileType
        super.init()
    }

    func open(completionHandler: ((Result<Contents, DocumentError>) -> Void)? = nil) {
        DispatchQueue.global().async {
            guard let data = try? self.source.data() else {
                DispatchQueue.main.async {
                    completionHandler?(.failure(.invalidSource))
                }
                return
            }

            do {
                let result = try self.load(from: data)
                DispatchQueue.main.async {
                    completionHandler?(result)
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler?(.failure(.invalidContents))
                }
            }
        }
    }

    func load(from data: Data) throws -> Result<Contents, DocumentError> {
        fatalError("This method must be overridden by subclasses")
    }

    func close(completionHandler: ((Bool) -> Void)? = nil) {

    }
}
