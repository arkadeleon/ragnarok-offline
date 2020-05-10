//
//  TextDocument.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/9.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

class TextDocument: Document {

    let encoding: String.Encoding

    private(set) var text: String?

    init(source: DocumentSource, encoding: String.Encoding = .ascii) {
        self.encoding = encoding
        super.init(source: source)
    }

    override func load(from contents: DocumentContents) throws {
        switch fileType {
        case "txt", "xml", "lua":
            let data = try contents.data()
            text = String(data: data, encoding: encoding)
        case "lub":
            // TODO: Decompile lub
            break
        default:
            break
        }
    }
}
