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

    var source: DocumentSource { get }

    init(source: DocumentSource)

    func open(completionHandler: @escaping (Result<Contents, DocumentError>) -> Void)

    func load(from data: Data) -> Result<Contents, DocumentError>
}

extension Document {

    func open(completionHandler: @escaping (Result<Contents, DocumentError>) -> Void) {
        DispatchQueue.global().async {
            guard let data = try? self.source.data() else {
                DispatchQueue.main.async {
                    completionHandler(.failure(.invalidSource))
                }
                return
            }

            let result = self.load(from: data)
            DispatchQueue.main.async {
                completionHandler(result)
            }
        }
    }

    func eraseToAnyDocument() -> AnyDocument<Contents> {
        AnyDocument(document: self)
    }
}

class AnyDocument<Contents>: NSObject {

    let source: DocumentSource
    let name: String
    let open: (@escaping (Result<Contents, DocumentError>) -> Void) -> Void

    init<D: Document>(document: D) where Contents == D.Contents {
        self.source = document.source
        self.name = document.source.name
        self.open = document.open
        super.init()
    }
}
