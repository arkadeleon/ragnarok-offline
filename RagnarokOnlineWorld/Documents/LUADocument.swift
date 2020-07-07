//
//  LUADocument.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/9.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

class LUADocument: Document {

    let source: DocumentSource
    let name: String

    required init(source: DocumentSource) {
        self.source = source
        self.name = source.name
    }

    func load() -> Result<String, DocumentError> {
        guard let data = try? source.data() else {
            return .failure(.invalidSource)
        }

        guard let string = String(data: data, encoding: .ascii) else {
            return .failure(.invalidContents)
        }

        return .success(string)
    }
}
