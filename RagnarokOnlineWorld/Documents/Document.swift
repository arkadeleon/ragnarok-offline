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

    func load<D: Document>(_ type: D.Type, from data: Data) throws -> D {
        let stream = DataStream(data: data)
        let document = try type.init(from: stream)
        return document
    }
}
