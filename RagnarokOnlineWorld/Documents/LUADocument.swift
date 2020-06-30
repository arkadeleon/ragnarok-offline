//
//  LUADocument.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/9.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

class LUADocument: Document<String> {

    let encoding: String.Encoding

    init(source: DocumentSource, encoding: String.Encoding = .ascii) {
        self.encoding = encoding
        super.init(source: source)
    }

    override func load(from data: Data) throws -> Result<String, DocumentError> {
        guard let string = String(data: data, encoding: encoding) else {
            return .failure(.invalidContents)
        }

        return .success(string)
    }
}
