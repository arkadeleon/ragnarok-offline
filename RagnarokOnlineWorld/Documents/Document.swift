//
//  Document.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/8.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

protocol Document {

    init(from stream: Stream) throws
}

enum DocumentError: Error {

    case invalidSource
    case invalidContents
}

class DocumentLoader {

    func load<T: Document>(_ type: T.Type, from url: URL) throws -> T {
        let stream = try FileStream(url: url)
        let document = try type.init(from: stream)
        return document
    }

    func load<T: Document>(_ type: T.Type, from data: Data) throws -> T {
        let stream = MemoryStream(data: data)
        let document = try type.init(from: stream)
        return document
    }
}
