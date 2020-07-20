//
//  TXTDocument.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/7/20.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

struct TXTDocument: Document {

    var string: String

    init(from stream: Stream) throws {
        let data = try stream.readToEnd()

        guard let string = String(data: data, encoding: .ascii) else {
            throw DocumentError.invalidContents
        }

        self.string = string
    }
}
