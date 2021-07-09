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

protocol Document {

    associatedtype Contents

    func load(from data: Data) -> Result<Contents, DocumentError>
}

extension Document {

    func eraseToAnyDocument(source: DocumentSource) -> AnyDocument<Contents> {
        AnyDocument(document: self, source: source)
    }
}

class AnyDocument<Contents>: NSObject {

    let load: (Data) -> Result<Contents, DocumentError>
    let source: DocumentSource
    let name: String
    let fileType: String

    init<D: Document>(document: D, source: DocumentSource) where Contents == D.Contents {
        self.load = document.load
        self.source = source
        self.name = source.name
        self.fileType = source.fileType
        super.init()
    }

    func open(completionHandler: @escaping (Result<Contents, DocumentError>) -> Void) {
        DispatchQueue.global().async {
            guard let data = try? self.source.data() else {
                DispatchQueue.main.async {
                    completionHandler(.failure(.invalidSource))
                }
                return
            }

            let result = self.load(data)
            DispatchQueue.main.async {
                completionHandler(result)
            }
        }
    }
}
